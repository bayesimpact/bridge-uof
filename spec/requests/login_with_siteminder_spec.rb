require 'cgi'
require 'rails_helper'

describe '[Logging in with Siteminder]', type: :request do
  describe '[handles cases where there is no correct cookie]' do
    before :each do
      Rails.configuration.x.login.siteminder_url_logout = '/logout'
      Rails.configuration.x.mail.feedback_to_address = 'feedback@example.com'
    end

    it 'redirects to logout url when no SMOFC cookie is set' do
      # Use rspec-rails rather than Capybara for this test, because Capybara
      # is bad at handling redirects.
      get welcome_path
      expect(response).to redirect_to(Rails.configuration.x.login.siteminder_url_logout)
    end

    it 'renders an error page when SMOFC cookie is invalid' do
      page.driver.browser.set_cookie("SMOFC=foobarbaz")
      visit welcome_path
      expect(page.status_code).to eq(401)
      expect(page).to have_content("Sorry, we weren't able to log you in to URSUS")
      expect(page).to have_content("Could not decrypt Siteminder (SMOFC) cookie")
      expect(page).to have_content(Rails.configuration.x.mail.feedback_to_address)
    end
  end

  describe '[with a valid SMOFC cookie set]' do
    before :each do
      login_with_siteminder(dont_handle_splash: true)
    end

    it 'logs in correctly' do
      visit welcome_path
      expect(page.status_code).to eq(200)
    end
    it 'creates a User object on login and re-uses it' do
      expect(User.count).to eq(0)
      visit welcome_path
      expect(User.count).to eq(1)
      visit welcome_path
      expect(User.count).to eq(1)
    end
    it 'allows a logged in user to load the dashboard, displaying their name' do
      handle_splash
      visit dashboard_path
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Dummy User")
    end
  end

  it 'updates the user\'s data if it changes in the cookie, without creating a new user' do
    user = build :dummy_user
    login_with_siteminder(dont_handle_splash: true, user: user)
    expect(User.count).to eq(0)  # Cookie is set, but no User created yet

    visit welcome_path  # Should create a user from the cookie params
    expect(User.count).to eq(1)
    expect(User.first.first_name).to eq('Dummy')

    user.first_name = 'Frank'
    login_with_siteminder(dont_handle_splash: true, user: user)
    visit welcome_path
    expect(User.count).to eq(1)
    expect(User.first.first_name).to eq('Frank')
  end

  # TODO: Add test to ensure that user account links (e.g. in the nav bar)
  #       change for devise vs siteminder logins.
end
