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
    expect(Feedback.count).to eq(0)
    visit feedback_path
    find('a', text: 'Click here for a feedback form').click
    fill_in 'Which part gave you difficulty', with: "Foo"
    fill_in 'Please explain', with: "Bar"
    expect { find('button[type=submit]').click }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(current_path).to eq(thank_you_path)

    expect(Feedback.count).to eq(1)
    f = Feedback.first
    expect(f.source).to eq("Foo")
    expect(f.content).to eq("Bar")
  end
end
