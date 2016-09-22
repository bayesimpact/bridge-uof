# Helpers related to explanatory text displayed to the user, which may customize
# themselves the type of user or specific page being viewed.
module ExplanationsHelper
  # This renders a nice explanatory alert box at the top of the
  # incident review page. The message needs to be different depending
  # on the type of user and status of the incident.
  def review_incident_explanation(user, status, submitted)
    text = begin
      if user.doj?
        nil
      elsif submitted
        "This incident has been finalized and sent to the state."
      elsif status == "in_review"
        review_incident_explanation_in_review_text(user)
      elsif status == "approved"
        review_incident_explanation_approved_text(user)
      end
    end

    text.present? ? content_tag(:div, text, class: %w(alert alert-info)) : ""
  end

  # This renders a nice explanatory alert box at the top of a
  # dashboard page. The message needs to be different depending
  # on the type of user and status of the incident.
  def dashboard_page_explanation(user, status, num_incidents)
    text = begin
      if num_incidents.zero?
        no_incidents_text(user, status)
      elsif status == "in_review"
        dashboard_page_explanation_in_review_text(user, num_incidents)
      elsif status == "approved"
        dashboard_page_explanation_approved_text(user, num_incidents)
      end
    end

    text.present? ? content_tag(:div, text, class: %w(alert alert-info)) : ""
  end

  private

    # Text that is displayed when any incident table on the dashboard page is empty.
    def no_incidents_text(user, status)
      case status
      when "draft"
        "You don't have any incident drafts yet. Click the red NEW INCIDENT button at the top to create one."
      when "in_review"
        "You don't have any incidents #{user.admin? ? 'to review' : 'awaiting review'} right now."
      when "approved"
        "#{user.admin? ? 'No incidents in your department' : 'None of your incidents'} are ready for " \
        "state submission yet."
      end
    end

    def review_incident_explanation_in_review_text(user)
      if user.admin?
        # Admin, needs to review it
        "Please review this incident. You may correct and edit it as needed."
      else
        # Non admin, awaiting review by an admin
        "This incident is awaiting review by your administrator, who may make changes. " \
        "Later, they will submit it to the state."
      end
    end

    def review_incident_explanation_approved_text(user)
      if user.admin?
        # Admin, approved-but-not-submitted incident
        "You (or another administrator) have reviewed and approved this incident. It will be included " \
        "in your annual state submission. If you make further changes, you (or another administrator) " \
        "will have to review and approve the incident again."
      else
        # Non admin, approved-but-not-submitted incident
        "This incident has been reviewed and approved by your administrator. " \
        "They may have made changes in the process."
      end
    end

    def dashboard_page_explanation_in_review_text(user, num_incidents)
      plural = (num_incidents > 1)
      if user.admin?
        "Please review #{plural ? 'these incidents' : 'this incident'}. " \
        "You may correct and edit #{plural ? 'them' : 'it'} as needed."
      else
        "#{plural ? 'These incidents are' : 'This incident is'} awaiting review by your administrator, " \
        "who may make changes. Later, they will submit #{plural ? 'them' : 'this incident'} to the state."
      end
    end

    def dashboard_page_explanation_approved_text(user, num_incidents)
      plural = (num_incidents > 1)
      if user.admin?
        "You (or another administrator) have reviewed and approved #{plural ? 'these incidents' : 'this incident'}. " \
        "It will be included in your annual state submission. You may still edit and make changes if necessary."
      else
        "#{plural ? 'These incidents have' : 'This incident has'} been reviewed and approved by your administrator. " \
        "They may have made changes in the process. " \
        "Later, your administrator will submit #{plural ? 'them' : 'this incident'} to the state."
      end
    end
end
