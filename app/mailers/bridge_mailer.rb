# Mailer class that sends out feedback emails.
class BridgeMailer < ActionMailer::Base
  default from: Rails.configuration.x.mail.from_address
  layout 'mailer'

  def feedback_email(feedback, user)
    @feedback = feedback
    @user = user

    mail(to: Rails.configuration.x.mail.feedback_to_address,
         cc: (user.email unless Rails.configuration.x.login.use_demo?),
         subject: "#{Rails.configuration.x.branding.ursus? ? 'URSUS feedback' : 'Feedback'} from #{@user.full_name}")
  end
end
