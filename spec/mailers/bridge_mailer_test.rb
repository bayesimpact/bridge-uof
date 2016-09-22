require 'rails_helper'

describe '[Mailer test]', type: :mailer do
  def extract_address_only(mail_target)
    # Email addresses may contain descriptive names, e.g. '"John Doe" <john.doe@example.com>'
    # This method extracts the john.doe@example.com part
    return mail_target unless mail_target.end_with?('>')
    mail_target.split('<')[-1][0..-2]
  end

  it 'extract_address_only helper method works' do
    expect(extract_address_only('"John Doe" <john.doe@example.com>')).to eq('john.doe@example.com')
    expect(extract_address_only('john.doe@example.com')).to eq('john.doe@example.com')
  end

  describe 'feedback_email' do
    before :all do
      @user = create :dummy_user
      @feedback = Feedback.create(source: "Source test", content: "Content test")
      @mail = BridgeMailer.feedback_email(@feedback, @user).deliver_now
    end

    it 'has the correct subject' do
      expect(@mail.subject).to eq("URSUS feedback from #{@user.full_name}")
    end

    it 'has the correct TO' do
      correct_addr = extract_address_only Rails.configuration.x.mail.feedback_to_address
      expect(@mail.to).to eq([correct_addr])
    end

    it 'CCs the user who sent the feedback' do
      expect(@mail.cc).to eq([@user.email])
    end

    it 'has the correct sender email' do
      correct_addr = extract_address_only Rails.configuration.x.mail.from_address
      expect(@mail.from).to eq([correct_addr])
    end

    it 'contains the feedback source and content' do
      expect(@mail.body.encoded).to match(@feedback.source)
      expect(@mail.body.encoded).to match(@feedback.content)
    end
  end
end
