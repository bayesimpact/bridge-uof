require 'rails_helper'

describe '[Screener Page]', type: :request do
  before :each do
    login
    new_incident
  end

  it 'requires answers before continuing' do
    expect(page).to have_content('Do I need to file this incident?')

    find('button[type=submit]').click
    expect(current_path).to end_with('/screener')
    expect(page).to have_content('There were problems with your form')
  end

  it "discards the incident if there's no need to file one" do
    choose_for_question 'No', text: 'multiple agencies'
    choose_for_question 'No', text: 'firearms discharged'
    choose_for_question 'No', text: 'use force on a civilian'
    choose_for_question 'No', text: 'civilians assault an officer'
    find('button[type=submit]').click

    expect(page).to have_content('Use of force reporting not required')

    find('a', text: 'Back to Dashboard').click

    expect(current_path).to eq(root_path)
    expect(page).to have_no_content('Resume')
  end

  it 'keeps filled fields on incomplete submission' do
    choose_for_question 'No', text: 'multiple agencies'
    choose_for_question 'No', text: 'firearms discharged'
    choose_for_question 'No', text: 'use force on a civilian'
    find('button[type=submit]').click

    expect(page).to have_content('There were problems with your form')

    within('div.form-group', text: 'firearms discharged') do
      expect(find(:radio_button, 'No')).to be_checked
    end
    within('div.form-group', text: 'use force on a civilian') do
      expect(find(:radio_button, 'No')).to be_checked
    end

    choose_for_question 'Yes', text: 'firearms discharged'
    find('button[type=submit]').click

    expect(page).to have_no_content('There were problems with your form')
    expect(current_path).to end_with('general_info')
    expect(page).to have_content('General Incident Information')
  end

  it 'highlights the field that is problematic when the form has problems' do
    choose_for_question 'No', text: 'multiple agencies'
    choose_for_question 'No', text: 'firearms discharged'
    choose_for_question 'Yes', text: 'use force on a civilian'
    choose_for_question 'No', text: 'civilians assault an officer'
    # Not answering the question about the injury of the civilian
    find('button[type=submit]').click

    expect(current_path).to end_with('/screener')
    expect(page).to have_content('There were problems with your form')

    expect(find(:css, '.has-error').text).to include('serious injury or death to a civilian')
  end

  it 'continues to the next page if needed' do
    answer_all_screener
    find('button[type=submit]').click

    expect(page).to have_no_content('No forms necessary')
    expect(current_path).not_to end_with('/screener')
  end
end
