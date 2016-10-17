# A General Info form within an incident report.
class GeneralInfo
  include Dynamoid::Document
  include AllowsPartialSave
  include Serializable
  include Constants::GeneralInfo

  before_validation :maybe_clear_additional_questions, :upcase_state

  table name: :general_infos
  belongs_to :incident

  field :ori, :string
  field :incident_date_str, :string
  field :incident_time_str, :string
  field :address, :string
  field :city, :string
  field :county, :string
  field :state, :string
  field :zip_code, :string
  field :multiple_locations, :boolean
  field :on_k12_campus, :boolean
  field :arrest_made, :boolean
  field :crime_report_filed, :boolean
  field :contact_reason, :string
  field :in_custody_reason, :string
  field :num_involved_civilians, :integer
  field :num_involved_officers, :integer

  validates :incident_date_str, incident_date: true
  validates :incident_time_str, incident_time: true
  validates :address, presence: true
  validates :city, presence: true
  validates :county, presence: true
  validates :state, inclusion: { in: STATES, message: "is invalid" }
  validates :zip_code, format: /\A[0-9]{5}\Z/i
  validates :multiple_locations, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :on_k12_campus, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :arrest_made, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :crime_report_filed, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :contact_reason, inclusion: { in: CONTACT_REASONS }
  validates :in_custody_reason, inclusion: { in: IN_CUSTODY_REASONS }, if: :contact_reason_is_in_custody_event?
  validates :num_involved_civilians, :num_involved_officers,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 20,
                            message: "should be a positive number (1-20)" }
  validates :ori, ori: true

  delegate :incident_id, to: :incident

  def display_agency
    if Rails.configuration.x.login.use_demo?
      incident.department
    else
      "#{incident.department} (#{incident.ori})"
    end
  end

  def display_datetime
    compute_datetime.strftime("%a %b %-d %Y - %H%M Hours")
  end

  def compute_datetime
    # Turn a datetime of the form "12/31/2016 1600" into the form "2016-12-31 16:00"
    # and then parse it into the application's given time zone.
    DateTime.strptime("#{incident_date_str} #{incident_time_str}", "%m/%d/%Y %H%M")
            .strftime("%Y-%m-%d %H:%M")
            .in_time_zone
  rescue ArgumentError
    nil
  end

  private

    def maybe_clear_additional_questions
      self[:in_custody_reason] = nil unless contact_reason_is_in_custody_event?
    end

    def contact_reason_is_in_custody_event?
      contact_reason == CONTACT_REASON_IN_CUSTODY
    end

    def upcase_state
      state.upcase! if state
    end
end
