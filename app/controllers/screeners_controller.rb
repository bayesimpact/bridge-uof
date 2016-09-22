# Controller for Screener form.
class ScreenersController < ApplicationController
  before_action :set_screener

  def create
    formatted_params = get_formatted_params(params, Screener)
    if @screener.update_attributes(formatted_params)
      if @screener.forms_necessary?
        @incident = Incident.create(user: @current_user, ori: @current_user.ori)
        # (ori may change later, based on the answer to the "contracting for ORI" question in the General Info page)

        @incident.screener = @screener
        @incident.audit_entries << AuditEntry.new(user: @current_user, custom_text: 'filled out the screener')
        redirect_to edit_incident_general_info_path(@incident)
      else
        render 'forms_not_necessary'
      end
    else
      render :new
    end
  end

  private

    def set_screener
      @screener = Screener.new
    end
end
