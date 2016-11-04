require 'rails_helper'

describe '[Logging in with Devise]', type: :request do
  let(:dummy_user) { build :dummy_user }

  it 'redirects root page to signin' do
    visit root_path
    expect(page).to have_current_path(new_user_session_path)
  end

  it 'redirects new incident page to signin' do
    visit new_incident_path
    expect(page).to have_current_path(new_user_session_path)
  end

  it 'allows login with valid credentials' do
    visit new_user_session_path
    fill_in 'Email', with: dummy_user.email
    fill_in 'Password', with: dummy_user.password
    find('input[type=submit]').click
    expect(page).to have_current_path(welcome_path)
  end

  it 'forbids login with wrong credentials' do
    visit new_user_session_path
    fill_in 'Email', with: dummy_user.email
    fill_in 'Password', with: dummy_user.password + '_'
    find('input[type=submit]').click
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content('Invalid email or password.')
  end
end
