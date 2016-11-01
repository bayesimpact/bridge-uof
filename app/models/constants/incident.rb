module Constants
  # Constants related to the Incident model.
  module Incident
    STATUS_TYPES = [:draft, :in_review, :approved, :deleted, :submitted].freeze

    STATUS_TEXTS_ADMIN = {
      nil => "Overview",
      "draft" => "My Drafts",
      "in_review" => "Needs Review",
      "approved" => "Review Complete",
      "state_submission" => "State Submission",
      "past_submissions" => "Past Submissions",
      "analytics" => "Analytics"
    }.freeze

    STATUS_TEXTS_NON_ADMIN = {
      nil => "Overview",
      "draft" => "My Drafts",
      "in_review" => "In Review",
      "approved" => "Review Complete",
      "past_submissions" => "Submitted to State"
    }.freeze

    STEPS = [:screener, :general, :civilians, :officers, :review].freeze
    STEP_URLS = [:screener, :general_info, :involved_civilians, :involved_officers, :review].freeze

    INCIDENT_ID_CODE_LENGTH = 3
    INCIDENT_ID_CODE_CHARS = 'ABCDEFGHJKMNPQRSTUVWXYZ'.freeze  # Letters that can't be easily confused with numbers

    # Used in demo site.
    MAX_FAKE_INCIDENTS_PER_BATCH = 10
    MAX_FAKE_INCIDENTS_TOTAL = 50

    # Used for schema generation in the bulk upload form.
    OPTIONS_PER_FIELD = {
      contact_reason: GeneralInfo::CONTACT_REASONS,
      in_custody_reason: GeneralInfo::IN_CUSTODY_REASONS,
      gender: InvolvedPerson::GENDERS,
      race: InvolvedPerson::RACES,
      asian_race: InvolvedPerson::ASIAN_RACES,
      injury_level: InvolvedPerson::INJURY_LEVELS,
      injury_type: InvolvedPerson::INJURY_TYPES,
      medical_aid: InvolvedPerson::GENDERS,
      received_force_location: InvolvedPerson::RECEIVED_FORCE_LOCATIONS,
      order_of_force_str: InvolvedCivilian::RECEIVED_FORCE_TYPES,
      mental_status: InvolvedCivilian::MENTAL_STATUSES,
      perceived_armed_weapon: InvolvedCivilian::PERCEIVED_WEAPONS,
      firearm_type: InvolvedCivilian::FIREARM_TYPES,
      received_force_type: InvolvedCivilian::RECEIVED_FORCE_TYPES | InvolvedOfficer::RECEIVED_FORCE_TYPES,
      custody_status: InvolvedCivilian::CUSTODY_STATUS_TYPES,
      resistance_type: InvolvedCivilian::RESISTANCE_TYPES,
      age: InvolvedCivilian::AGES | InvolvedOfficer::AGES,
      confirmed_armed_weapon: InvolvedCivilian::CONFIRMED_WEAPONS,
      officer_used_force_reason: InvolvedOfficer::OFFICER_USED_FORCE_REASON_TYPES,
      dress: InvolvedOfficer::DRESS_TYPES
    }.freeze
  end
end
