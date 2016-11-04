require 'rails_helper'

describe '[Devise-related tests]', type: :request do
  it 'allows Devise login via test helper methods' do
    login_with_devise
    logout
  end

  it 'sign-up page is linked from sign-in page' do
    visit new_user_session_path
    click_link 'Not registered'
    expect(current_path).to eq(new_user_registration_path)
  end

  def visit_registration_and_fill_form
    visit new_user_registration_path
    fill_in 'First Name', with: 'Elvis'
    fill_in 'Last Name', with: 'Presley'
    fill_in 'Email', with: 'elvis@example.com'
    fill_in 'ORI', with: 'other-ORI'
    fill_in 'Department', with: 'other-dept'
    fill_in 'Role', with: 'other-role'
    fill_in 'User ID (from ECARS)', with: 'other-user-id'
    fill_in 'user_password', with: 'p@ssw0rd'
    fill_in 'Confirm password', with: 'p@ssw0rd'
  end

  it 'allows sign up of a new user' do
    visit_registration_and_fill_form
    find('input[type=submit]').click
    expect(current_path).to eq(welcome_path)
  end

  describe '[with an existing user]' do
    let(:dummy_user) { create :dummy_user }

    it 'allows sign up of an existing user with a new userid' do
      visit new_user_registration_path
      fill_in 'First Name', with: dummy_user.first_name
      fill_in 'Last Name', with: dummy_user.last_name
      fill_in 'Email', with: dummy_user.email
      fill_in 'ORI', with: dummy_user.ori
      fill_in 'Department', with: dummy_user.department
      fill_in 'Role', with: dummy_user.role
      fill_in 'User ID (from ECARS)', with: (dummy_user.user_id + "2")
      fill_in 'user_password', with: dummy_user.password
      fill_in 'Confirm password', with: dummy_user.password
      find('input[type=submit]').click
      expect(current_path).to eq(welcome_path)
    end

    it 'forbids sign up of an existing user with the same userid' do
      visit_registration_and_fill_form
      fill_in 'User ID (from ECARS)', with: dummy_user.user_id
      find('input[type=submit]').click
      expect(current_path).not_to eq(welcome_path)
      expect(page).to have_content('User is already taken')
    end
  end
end
