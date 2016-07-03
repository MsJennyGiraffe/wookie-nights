require 'rails_helper'

RSpec.feature "visitor can filter search results" do
  scenario "visitor visits a set of search results" do
    planet = create(:planet, name: "Hoth")
    create_list(:space, 4, planet: planet)
    visit '/spaces?utf8=%E2%9C%93&planet=Hoth&occupancy=&start_date=&end_date=&commit=search'

    within ".filter-nav" do
      expect(page).to have_selector('#space_filter_climates')
    end

    within "#all_socks" do
      expect(page).to have_selector('.one-sock', count: 4)
    end
  end
end
