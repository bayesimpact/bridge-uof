require 'rails_helper'

describe '[Visit and event tracking]', type: :request do
  let(:user) { User.first }

  before :each do
    login

    # We don't care about the events that were triggered by login.
    Event.all.each(&:destroy)
  end

  it 'tracks visits and events' do
    # Visiting one page should create a visit and one event.

    visit dashboard_path

    expect(Visit.count).to eq(1)
    expect(Visit.first.user).to eq(user)

    expect(Event.count).to eq(1)
    expect(Event.first.name).to eq('incidents#index')
    expect(Event.first.visit.id).to eq(Visit.first.id)
    expect(Event.first.user).to eq(user)

    # Visiting another page should create new events, but the visit should stay the same.

    visit new_incident_path

    expect(Visit.count).to eq(1)
    expect(Event.count).to be > 1
  end
end
