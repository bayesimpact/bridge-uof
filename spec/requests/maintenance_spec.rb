require 'rails_helper'

describe '[Maintenance mode]', type: :request do
  it 'Maintenance mode can be switched on and off' do
    login(dont_handle_splash: true)

    visit root_path
    expect(page).to have_content('Welcome')

    GlobalState.start_maintenance_mode!

    visit root_path
    expect(page).to have_content('Down for Maintenance')

    GlobalState.stop_maintenance_mode!

    visit root_path
    expect(page).to have_content('Welcome')
  end
end
