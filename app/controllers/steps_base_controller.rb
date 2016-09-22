# Base class for controllers representing steps in the incident form.
class StepsBaseController < ApplicationController
  before_action :set_incident, :make_sure_step_is_accessible

  private

    # If the current step isn't accessible yet, redirect to the last accessible step.
    def make_sure_step_is_accessible
      return redirect_to incident_path(@incident) unless @incident.step_accessible? current_step
    end

    # If a user edits an approved incident, it should be moved back to the review stage to require a fresh approval.
    def move_incident_to_in_review_if_necessary!
      @incident.in_review! if @incident.approved?
    end

    # Returns the current step (one of Incident::STEP_URLS).
    def current_step
      case params[:controller]
      when 'screeners'
        :screener
      when 'general_infos'
        :general_info
      when 'involved_civilians'
        :involved_civilians
      when 'involved_officers'
        :involved_officers
      end
    end
end
