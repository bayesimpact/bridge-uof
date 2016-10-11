require 'rails_helper'

describe '[Splash page]', type: :request do
  it 'Renders the splash page for first-time visitors' do
    login(dont_handle_splash: true)
    visit root_path
    expect(current_path).to end_with('/welcome')
    expect(page).to have_content('Welcome')

    # Until the user clicks 'ENTER' on the splash page, they'll keep getting
    # redirected there
    visit root_path
    expect(current_path).to end_with('/welcome')
    expect(page).to have_content('Welcome')

    click_button('ENTER')
    expect(current_path).not_to end_with('/welcome')  # Sent away from splash
    visit root_path
    expect(current_path).not_to end_with('/welcome')  # Doesn't get splash again
    visit welcome_path
    expect(current_path).to end_with('/welcome')  # Can still explicitly visit
  end
end
