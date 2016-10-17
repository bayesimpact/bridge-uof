# This class is a singleton (see HasOnlyOneInstance).
# Use the accessor functions below to get and set.
class GlobalState
  include Dynamoid::Document
  include HasOnlyOneInstance

  field :submission_open, :boolean
  field :last_complete_submission_year, :integer

  validates :submission_open, inclusion: [true, false]

  self.DEFAULT_FIELDS = {
    # Ursus begins as if we've already closed out for 2015
    submission_open: false,
    last_complete_submission_year: 2015
  }

  # In a given calendar year, state submission goes through 3 phases:
  # 1) Not yet open. Waiting for DOJ administrator to start accepting submissions.
  # 2) Open and accepting submissions (for incidents from last year).
  # 3) Closed for the year.
  # At the next calendar year, things will roll over to phase 1.
  # What messages we show users depends on which phase they are in.

  def self.submission_not_yet_open?
    # Helper to check it the window hasn't yet been opened for the year
    !submission_open? && instance.last_complete_submission_year != Time.current.year - 1
  end

  def self.submission_open?
    # In 'DEMO' mode we wedge the submission window permanently open. Otherwise,
    # it depends on DOJ action.
    instance.submission_open || Rails.configuration.x.login.use_demo?
  end

  def self.submission_closed_for_year?
    # Helper to check it the window is closed after being open for the year.
    !submission_not_yet_open? && !submission_open?
  end

  def self.open_submission_window!
    instance.update_attributes(submission_open: true) unless submission_open?
  end

  def self.close_submission_window!
    if submission_open?
      instance.update_attributes(submission_open: false, last_complete_submission_year: Time.current.year - 1)
    end
  end

  def self.toggle_submission_window!
    submission_open? ? close_submission_window! : open_submission_window!
  end

  def self.valid_new_incident_years
    # Returns an array of years that new incidents can be created for.
    # Users can always create incidents for the current year, and also
    # for last year iff submission hasn't closed out for the year.
    submission_closed_for_year? ? [Time.current.year] : [Time.current.year - 1, Time.current.year]
  end
end
