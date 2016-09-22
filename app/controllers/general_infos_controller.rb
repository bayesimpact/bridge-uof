# Controller for General Info form.
class GeneralInfosController < StepsBaseController
  before_action :set_general_info
  after_action :move_incident_to_in_review_if_necessary!, only: [:update]

  def edit
    render :edit
  end

  def update
    formatted_params = get_formatted_params(params, GeneralInfo)

    if params[:validate_and_continue] != "true"
      partial_save(formatted_params)
    else
      # Attempt a full (not partial) save.
      @general_info.partial = false

      # Save the incident ORI and year, so that we can later check if it's changed.
      old_incident = { ori: @incident.ori, year: @incident.year }

      # Try to validate, save, and audit the updated fields
      check_that_ori_is_valid(formatted_params)
      save_succeeded = save_and_audit(@general_info, formatted_params)
      return render :edit unless save_succeeded

      # Update successful, fields valid.
      @incident.general_info = @general_info
      @incident.ori = @ori

      regenerate_incident_id_if_necessary!(old_incident)
      remove_people_if_necessary_to_match_counts!

      redirect_to @incident
    end
  end

  private

    def set_general_info
      @general_info = @incident.general_info.target || GeneralInfo.new
    end

    def partial_save(formatted_params)
      @general_info.partial_save(formatted_params)
      @incident.general_info = @general_info
      redirect_to dashboard_path
    end

    # Check that the incident ORI is allowed. (We can't do this check on the model level
    # b/c the GeneralInfo model doesn't have access to the incident or user yet.)
    # If invalid, adds an error to the GeneralInfo model.
    def check_that_ori_is_valid(formatted_params)
      @ori = formatted_params['contracting_for_ori'] || @incident.ori
      if @current_user.allowed_oris.exclude? @ori
        @general_info.errors.add(:contracting_for_ori, "invalid ORI")
      end
    end

    # If an incident id hasn't been generated yet, or the incident ori or year
    # is changed, regenerate the incident id for the incident.
    def regenerate_incident_id_if_necessary!(old_incident)
      if @incident.incident_id.blank? || @incident.ori != old_incident[:ori] || @incident.year != old_incident[:year]
        @incident.incident_id.generate!
      end
    end

    # If the user reduced the number of people involved, adjust those arrays.
    def remove_people_if_necessary_to_match_counts!
      while @incident.involved_civilians.length > @general_info.num_involved_civilians
        last_civilian = @incident.involved_civilians[-1]
        @incident.audit_entries << AuditEntry.new(user: @current_user,
                                                  custom_text: "deleted civilian #{last_civilian.id}")
        @incident.involved_civilians.delete(last_civilian)
      end

      while @incident.involved_officers.length > @general_info.num_involved_officers
        last_officer = @incident.involved_officers[-1]
        @incident.audit_entries << AuditEntry.new(user: @current_user,
                                                  custom_text: "deleted officer #{last_officer.id}")
        @incident.involved_officers.delete(last_officer)
      end
    end
end
