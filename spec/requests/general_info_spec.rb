require 'rails_helper'

describe '[General Info Page]', type: :request do
  before :each do
    login
    create_partial_incident :general
    expect(current_path).to end_with('/general_info')
  end

  def expect_form_success
    expect(current_path).not_to end_with('/general_info')
    expect(page).to have_no_content('General Incident Information')
    expect(page).to have_no_content('There were problems with your form')
  end

  def expect_form_failure
    expect(current_path).to end_with('/general_info')
    expect(page).to have_content('General Incident Information')
    expect(page).to have_content('There were problems with your form')
  end

  it 'is linked directly from dashboard' do
    visit_status :draft
    find('a', text: 'Edit').click

    expect(current_path).to end_with('/general_info')
    expect(page).to have_content('General Incident Information')
  end

  it 'requires answers before continuing' do
    find('button[type=submit]').click

    expect_form_failure
  end

  it 'continues to the next page when complete' do
    answer_all_general_info
    find('button[type=submit]').click

    expect_form_success
  end

  it "doesn't allow incidents with years that have already been submitted for" do
    AgencyStatus.find_or_create_by_ori(User.first.ori)
                .mark_year_submitted!(Time.current.year - 1)

    answer_all_general_info(date: Time.zone.today - 1.year)
    find('button[type=submit]').click

    expect_form_failure
  end

  it 'allows partial save', driver: :poltergeist do
    today_str = Time.zone.today.strftime('%m/%d/%Y')
    fill_in 'Date', with: today_str
    fill_in 'Time', with: '1830'
    click_link "I'm not done yet"

    expect(current_path).to eq('/dashboard')

    visit_status :draft
    click_link 'Edit'

    expect(current_path).to end_with('/general_info')
    expect(page).to have_no_content('There were problems with your form')
    expect(page).to have_field("Date", with: today_str)
    expect(page).to have_field("Time", with: "1830")
  end

  it "moves to the next page iff Save and Continue is clicked", driver: :poltergeist do
    # Even when all the questions are filled out, the Screener should still be
    # considered 'invalid' when partial=true.
    answer_all_general_info
    click_link "I'm not done yet"
    visit_status :draft
    click_link 'Edit'

    expect(current_path).to end_with('/general_info')

    click_button "Save and Continue"

    expect(current_path).to end_with('/involved_civilians/new')
  end
end
