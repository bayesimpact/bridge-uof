
# Controller for viewing, creating, deleting, and updating status of incidents.
class IncidentsController < ApplicationController
  before_action :redirect_doj_users, only: [:index, :new, :submit_to_state!]
  before_action :set_status
  before_action :set_incident, only: [:show, :update, :review, :destroy]
  before_action :set_incidents, only: [:index, :submit_to_state!]
  before_action :set_year, only: [:index, :json]

  def new
    redirect_to new_screener_url
  end

  def index
    if @status == 'analytics'
      raise ActionController::BadRequest.new unless @current_user.admin?

      @analytics = ComputeAnalyticsQuery.new.run(user: @current_user, year: @year)
    end
  end

  def json
    incidents = GetAllIncidentsQuery.new.run(user: @current_user)
                                    .reject(&:draft?)  # Ignore draft incidents for stats.
                                    .select { |i| i.year == @year || @year.blank? }  # Optionally filter by year.

    stats = incidents.map { |i| i.stats(exclude_year: @year.present?) }

    render json: stats
  end

  def submit_to_state!
    raise ActionController::BadRequest.new unless @current_user.admin?

    begin
      check_if_able_to_submit_to_state
    rescue BridgeExceptions::UnableToSubmitError => e
      flash[:error] = e.message
      return redirect_to dashboard_url(status: 'state_submission')
    end

    @current_user.allowed_oris.each do |ori|
      agency = AgencyStatus.where(ori: ori).first || AgencyStatus.create(ori: ori)
      agency.mark_year_submitted!(Time.last_year)
      Incident.all.select { |i| i.ori == ori && i.year == Time.last_year && i.approved? }.each do |i|
        i.update_attributes(status: 'submitted')
      end
    end

    redirect_to dashboard_url(status: 'past_submissions')
  end

  def update
    params_permitted = params.require(:incident).permit([:status])
    if @incident.update_attributes(params_permitted)
      if @incident.in_review?
        flash[:notice] = "Your incident (#{@incident.incident_id}) has been sent for review."
      elsif @incident.approved?
        flash[:notice] = "You have approved incident #{@incident.incident_id}."
      end
      redirect_to dashboard_path
    else
      redirect_to @incident
    end
  end

  def review
    if @incident.step_accessible?(:review)
      render 'review'
    else
      redirect_to incident_path(@incident)
    end
  end

  def show
    redirect_to incident_url(@incident) + '/' + @incident.next_step.to_s
  end

  def destroy
    if Rails.configuration.x.login.use_demo?
      @incident.destroy
    else
      save_and_audit(@incident, status: 'deleted')
    end
    redirect_to dashboard_url(status: @status)
  end

  def upload
    if params[:file].present?
      @output = BulkImportService.import(params[:file], @current_user)
    end

    @json_schema = Incident.json_schema
    @xml_schema = Incident.xml_schema

    # Set the incident counts in the sidebar right before rendering to reflect imported incidents.
    set_incidents
  end

  # Generate at most Incident::MAX_FAKE_INCIDENTS_PER_BATCH fake incidents, but
  # don't let there be more than Incident::MAX_FAKE_INCIDENTS_TOTAL incidents in total.
  def create_fake
    unless Rails.configuration.x.login.use_demo?
      raise ActionController::RoutingError.new('Not Found')
    end
    num_existing = @current_user.incidents.reject(&:deleted?).count
    if num_existing >= Incident::MAX_FAKE_INCIDENTS_TOTAL
      flash[:notice] = "In this demo, you can only generate up to " \
                       "#{Incident::MAX_FAKE_INCIDENTS_TOTAL} incidents in total."
      return redirect_to :back
    end

    num_generated = [Incident::MAX_FAKE_INCIDENTS_TOTAL - num_existing, Incident::MAX_FAKE_INCIDENTS_PER_BATCH].min

    FactoryGirl.create_list :incident, num_generated do |incident|
      @current_user.incidents << incident
      @current_user.save

      incident.update_attribute(:ori, @current_user.ori)
      incident.approved!
    end

    note_about_incident_count = begin
      if num_generated == Incident::MAX_FAKE_INCIDENTS_PER_BATCH
        "giving you #{@current_user.incidents.reject(&:deleted?).count} total"
      else
        "in this demo, you can only generate up to #{Incident::MAX_FAKE_INCIDENTS_TOTAL} incidents in total"
      end
    end

    flash[:notice] = "You have generated #{num_generated} incidents with random data (#{note_about_incident_count}). " \
                     "Use the links on the left to view, submit, or analyze them."
    redirect_to :back
  end

  protected

    def set_status
      @status_texts = @current_user.admin? ? Incident::STATUS_TEXTS_ADMIN : Incident::STATUS_TEXTS_NON_ADMIN

      @status = params[:status].present? ? params[:status] : nil
      @status_text = @status_texts[@status]
    end

    def set_year
      @year = params[:year].try(:to_i_safe)
    end

    def redirect_doj_users
      redirect_to doj_path if @current_user.doj?
    end

    def set_incidents
      @incidents = DashboardIncidentsQuery.new.run(user: @current_user)

      @employee_draft_counts = EmployeeDraftCountsQuery.new.run(user: @current_user) if @current_user.admin?
      if @status == 'past_submissions'
        @past_incidents_by_year = PastSubmissionsQuery.new.run(user: @current_user)
      end

      @incident_counts_by_type = Hash[Incident::STATUS_TYPES.map do |status|
        [status, @incidents.count { |i| i.status == status.to_s }]
      end]

      @incident_counts_by_type_last_year = Hash[Incident::STATUS_TYPES.map do |status|
        [status, @incidents.select { |i| i.year == Time.last_year }.count { |i| i.status == status.to_s }]
      end]

      # Whittle down to the incidents to display on this particular page.
      @incidents.select! do |i|
        i.status == @status || (@status == 'state_submission' && i.status == 'approved' && i.year == Time.last_year)
      end
    end

    def check_if_able_to_submit_to_state
      if !GlobalState.submission_open?
        raise BridgeExceptions::UnableToSubmitError.new "Submission to the state is not currently open for #{Time.last_year}"
      elsif @agency_last_submission_year == Time.last_year
        raise BridgeExceptions::UnableToSubmitError.new "You have already submitted for #{Time.last_year}"
      elsif params[:submission_year] != Time.last_year.to_s
        year = params[:submission_year] || '<no year specified>'
        raise BridgeExceptions::UnableToSubmitError.new "Currently accepting submissions for #{Time.last_year} " \
                                                       "(you tried to submit for #{year})"
      elsif @incident_counts_by_type[:draft] > 0 || @incident_counts_by_type[:in_review] > 0
        num_unreviewed = @incident_counts_by_type[:draft] + @incident_counts_by_type[:in_review]
        raise BridgeExceptions::UnableToSubmitError.new "Your agency has #{num_unreviewed.pluralize('unreviewed incident')}"
      end
    end
end
