# Base class for controllers representing Involved Civilian and Involved Officer forms.
# Subclasses must implement a person_type() method.
class InvolvedPersonsController < StepsBaseController
  before_action :set_persons_and_indices
  before_action :set_involved_person, except: [:new, :create, :index]
  before_action :redirect_if_unnecessary, only: [:new, :create]
  after_action :move_incident_to_in_review_if_necessary!, only: [:create, :update, :destroy]

  def index
    if @involved_persons.any?(&:invalid?)
      # At least one involved person is invalid - edit that person.
      invalid_person_idx = @involved_persons.index(&:invalid?)
      redirect_to edit_person_path(@type, @incident, invalid_person_idx)
    elsif @involved_persons.length < @num_involved_persons
      # Not enough persons entered yet - create a new one.
      redirect_to new_person_path(@type, @incident)
    else
      # All involved persons are valid - so just edit the first.
      redirect_to edit_person_path(@type, @incident, 0)
    end
  end

  def new
    @person = @klass.new
    render_person
  end

  def edit
    render_person
  end

  def create
    @person = @klass.new
    create_or_update(true)
  end

  def update
    create_or_update(false)
  end

  def destroy
    # Don't allow deleting the last civilian or officer.
    if @num_involved_persons >= 1
      @persons_association.delete(@person)

      # Update # of civilians/officers.
      if @type_civilian
        @incident.general_info.num_involved_civilians -= 1
      elsif @type_officer
        @incident.general_info.num_involved_officers -= 1
      end
      @incident.general_info.save!

      # Add an audit entry.
      @incident.audit_entries << AuditEntry.new(user: @current_user, custom_text: "deleted #{@type} #{@person.id}")
    end

    redirect_to @incident
  end

  private

    def set_persons_and_indices
      @type = person_type
      if @type == :civilian
        @klass = InvolvedCivilian
        @persons_association = @incident.involved_civilians
        @num_involved_persons = @incident.general_info.num_involved_civilians
      elsif @type == :officer
        @klass = InvolvedOfficer
        @persons_association = @incident.involved_officers
        @num_involved_persons = @incident.general_info.num_involved_officers
      else
        raise ActionController::BadRequest.new
      end

      @involved_persons = InvolvedPerson.sorted_persons(@persons_association)
      @current_person_index = @involved_persons.length
      @disabled_beyond = @involved_persons.all?(&:valid?) ? @involved_persons.length : @involved_persons.length - 1
    end

    def redirect_if_unnecessary
      return redirect_to @incident if all_persons_complete?
    end

    def set_involved_person
      unless params[:id].integer? && params[:id].to_i < @involved_persons.length
        # Not an integer or invalid integer
        raise ActionController::RoutingError.new('Not Found')
      end

      @current_person_index = params[:id].to_i
      @person = @involved_persons[@current_person_index]
    end

    def create_or_update(creating)
      formatted_params = get_formatted_params(params, @klass)

      if params[:validate_and_continue] == "true"
        @person.partial = false
        if save_and_audit(@person, formatted_params)
          @persons_association << @person if creating
          redirect_to incident_path(@incident)
        else
          render_person
        end
      else
        @person.partial_save(formatted_params)
        @persons_association << @person if creating
        redirect_to dashboard_path
      end
    end

    def all_persons_complete?
      @involved_persons.to_a.count(&:valid?) >= @num_involved_persons
    end

    def render_person
      render "edit_#{person_type}"
    end
end
