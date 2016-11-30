# DynamoDB configuration goes here.

Dynamoid.configure do |config|
  config.namespace = ENV['DYNAMO_TABLE_PREFIX'] || "ursus_#{Rails.env}"
  config.write_capacity = 1
  config.read_capacity = 1
end

MODELS = [
  User, Incident, Screener, GeneralInfo, InvolvedCivilian, InvolvedOfficer,
  Feedback, AuditEntry, ChangedField, AgencyStatus, GlobalState, Visit, Event,
  AdditionalSubmissionInformation
].freeze

Rails.configuration.after_initialize do
  # Initialize tables, if necessary. Do this after initialization so that
  # we are sure that Devise has been loaded.
  MODELS.each do |model|
    3.tries(catching: Aws::DynamoDB::Errors::LimitExceededException) do
      model.create_table
    end
  end
end
