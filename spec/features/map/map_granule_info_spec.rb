# EDSC-93: As a user, I want to see an indication of granule counts under my
#          mouse cursor so I may find more information about granules under
#          that point

require "spec_helper"

describe "Map Granule information", :reset => false do
  original_wait_time = nil

  before :all do
    Capybara.reset_sessions!
    visit "/search"

    first_dataset_result.click_link "Add dataset to the current project"
  end

  after :all do
    reset_project
  end

  def map_mousemove(selector='#map', x=10, y=10, lat=10, lng=10)
    script = """
             var target = $('#{selector}')[0];
             var e = {containerPoint: {x: #{x}, y: #{y}},
                      originalEvent: {target: target},
                      latlng: {lat: #{lat}, lng: #{lng}}};
             window.edsc.page.map.map.fire('mousemove', e);
             null;
    """
    page.evaluate_script(script)
    wait_for_xhr
  end

  def map_mouseout
    page.evaluate_script("window.edsc.page.map.map.fire('mouseout');  null;")
    wait_for_xhr
  end

  context 'when viewing dataset results' do
    context 'hovering on the map' do
      before :all do
        map_mousemove()
      end

      after :all do
        map_mouseout()
      end

      it 'displays no tooltip' do
        expect(page).to have_no_content('Granules at this location')
      end
    end
  end

  context 'when viewing a project' do
    before :all do
      dataset_results.click_link "View Project"
      expect(page).to have_css('.panel-list-selected')
      page.evaluate_script('console.log("view project");')
    end

    after :all do
      reset_overlay
      expect(page).to have_no_css('.panel-list-selected')
    end

    context 'with a dataset selected' do
      context 'hovering on the map' do
        before :all do
          map_mousemove()
        end

        after :all do
          map_mouseout()
        end

        it 'displays a tooltip containing granule counts under the point' do
          expect(page).to have_content('0 Granules at this location')
        end

        context 'and moving the mouse again' do
          before :all do
            map_mousemove('#map', 50, 50, 39.1, -96.6)
          end

          it 'updates the granule count tooltip' do
            expect(page).to have_content('39 Granules at this location')
          end
        end
      end

      context 'hovering on the map toolbar' do
        before :all do
          map_mousemove('a.leaflet-draw-draw-marker')
        end

        after :all do
          map_mouseout()
        end

        it 'displays no tooltip' do
          expect(page).to have_no_content('Granules at this location')
        end
      end
    end

    context 'with no dataset selected' do
      before :all do
        first_project_dataset.click
      end

      after :all do
        first_project_dataset.click
      end

      context 'hovering on the map' do
        before :all do
          map_mousemove()
        end

        after :all do
          map_mouseout()
        end

        it 'displays no tooltip' do
          expect(page).to have_no_content('Granules at this location')
        end
      end
    end
  end
end