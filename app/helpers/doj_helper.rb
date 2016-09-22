# Helper methods pertaining to the DOJ dashboard.
module DojHelper
  def submission_window_button_text
    if GlobalState.submission_open?
      "Close the window now"
    elsif GlobalState.submission_not_yet_open?
      "Open the window now"
    else
      "Re-open the window for #{Time.current.year - 1}"
    end
  end
end
