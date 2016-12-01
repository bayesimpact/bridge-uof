# View helper methods for additional_submission_information.
module AdditionalSubmissionInformationHelper
  def valid_year
    Time.last_year.to_s
  end

  def current_year_voluntary_info?(ori)
    AdditionalSubmissionInformation.where(submission_year: valid_year)
                                   .any? { |asi| asi.ori == ori }
  end
end
