# Load and validate email configuration.

mail_config = Rails.application.config.x.mail

unless ENV['MAIL_FROM'].present?
  raise 'Must set MAIL_FROM to an email address for the app\'s outgoing emails.'
end
mail_config.from_address = ENV['MAIL_FROM']

unless ENV['FEEDBACK_MAIL_TO'].present?
  raise 'Must set FEEDBACK_MAIL_TO to an email address for the app to send user feedback.'
end
mail_config.feedback_to_address = ENV['FEEDBACK_MAIL_TO']
