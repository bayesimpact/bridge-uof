# DynamoDB configuration goes here.

Dynamoid.configure do |config|
  config.adapter = 'aws_sdk_v2'
  config.warn_on_scan = true
  config.namespace = ENV['DYNAMO_TABLE_PREFIX'] || "ursus_#{Rails.env}"
end

Rails.configuration.after_initialize do
  # Initialize tables, if necessary. Do this after initialization so that
  # we are sure that Devise has been loaded.
  [
    User, Incident, Screener, GeneralInfo, InvolvedCivilian, InvolvedOfficer,
    Feedback, AuditEntry, ChangedField, AgencyStatus, GlobalState,
    Visit, Event
  ].each do |model|
    3.tries(catching: Aws::DynamoDB::Errors::LimitExceededException) do
      model.create_table(write_capacity: 1, read_capacity: 1)
    end
  end
end
