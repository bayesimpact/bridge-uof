# Voluntary submission information upon state submission.
class AdditionalSubmissionInformation
  include Dynamoid::Document
  include Serializable

  # fields
  field :ori, :string
  field :submission_year, :string
  field :k9_officer_severely_injured_count, :integer
  field :non_sworn_uniformed_injured_or_killed_count, :integer
  field :civilians_injured_or_killed_by_non_sworn_uniformed_count, :integer

  # callbacks
  after_initialize :assign_submission_year

  # validations
  validates :k9_officer_severely_injured_count,
            :non_sworn_uniformed_injured_or_killed_count,
            :civilians_injured_or_killed_by_non_sworn_uniformed_count,
            numericality: { only_integer: true,
                            greater_than: 0 }

  validates :ori, :k9_officer_severely_injured_count,
            :non_sworn_uniformed_injured_or_killed_count,
            :civilians_injured_or_killed_by_non_sworn_uniformed_count,
            :submission_year,
            presence: true

  validates :ori, uniqueness: { scope: [:submission_year],
                                message: 'with voluntary information has already been submitted.' }

  # instance methods
  def assign_submission_year
    self.submission_year = Time.last_year.to_s
  end

  def agency
    AgencyStatus.find_by_ori(ori)
  end
end
