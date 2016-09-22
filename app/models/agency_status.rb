# A submission status of an ORI.
# Simply stores an ORI and the last year that agency made a state submission.
class AgencyStatus
  include Dynamoid::Document

  table key: :ori

  field :ori, :string
  field :complete_submission_years_set, :set, default: Set.new

  validates :ori, presence: true, uniqueness: true

  def self.get_agency_last_submission_year(ori)
    agency_status = find_by_ori(ori)
    if agency_status.nil?
      -1
    else
      agency_status.last_submission_year
    end
  end

  def self.find_by_ori(ori)
    find(ori)  # Since ORI is the primary key
  end

  def last_submission_year
    if complete_submission_years.empty?
      -1
    else
      complete_submission_years.max
    end
  end

  def mark_year_submitted!(year)
    complete_submission_years_set.add(year.to_s)  # Store as string
    save!
  end

  def complete_submission_years
    complete_submission_years_set.map(&:to_i).sort  # Convert string -> int
  end
end
