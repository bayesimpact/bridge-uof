# Generic helper methods that don't belong in other Helper modules go here.
module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  def valid_year
    Time.last_year.to_s
  end

  def current_year_voluntary_info?(ori)
    AdditionalSubmissionInformation.where(submission_year: valid_year)
      .any? { |asi| asi.ori == ori }
  end

  def class_names
    [controller_name, action_name].map(&:parameterize).join(' ')
  end
end
