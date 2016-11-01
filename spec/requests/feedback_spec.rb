require 'rails_helper'

describe '[Feedback and feedback email tests]', type: :request do
  before :each do
    login
  end

  it 'Loads the feedback page when the help button is clicked' do
    click_link 'HELP'
    expect(current_path).to eq(feedback_path)
  end

  it 'Saves feedback and sends it in an email', driver: :poltergeist do
    visit feedback_path
    click 'Click here for a feedback form'
    fill_in 'Which part gave you difficulty', with: "Test source"
    fill_in 'Please explain', with: "Test content"
    expect { find('button[type=submit]').click }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(current_path).to eq(thank_you_path)
  end
end
