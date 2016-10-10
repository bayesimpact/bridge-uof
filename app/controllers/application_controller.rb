# Base class for all controllers in Ursus.
class ApplicationController < ActionController::Base
  include Authenticates
  include PathHelper

  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  before_action :log_params
  before_action :consider_splash, unless: :devise_controller?

  after_action :track_action

  protected

    def set_incident
      @incident_id = params[:incident_id] || params[:id]
      @incident = Incident.find(@incident_id)

      if @incident.present?
        check_authorization
      else
        logger.error "No such incident: #{@incident_id || '<no id>'}"
        redirect_to dashboard_path
      end
    end

    def consider_splash
      redirect_to welcome_path unless @current_user.splash_complete
    end

    def log_params
      logger.debug 'Request params: ' + params.to_s
    end

    # Track the controller, action, and parameters as an event in Ahoy.
    def track_action
      unless ENV['DISABLE_TRACKING'] == 'true'
        ahoy.track "#{controller_name}##{action_name}", request.filtered_parameters
      end
    end

    # Given a Parameters object and the class of a model that is being updated,
    # permits only the permitted fields for the given model,
    # fills out empty array fields if necessary,
    # and returns a hash of parameters cast to the appropriate data types.
    def get_formatted_params(params, model_class)
      permitted_params = params.require(model_class.name.underscore.to_sym)
                               .permit(model_class.permitted_fields)

      # Empty arrays are not sent from client, so always populate those fields
      # with [] to potentially update an existing array.
      model_class.array_fields.each do |key|
        permitted_params[key] ||= []
      end

      Hash[permitted_params.map do |key, value|
        type = model_class.attributes[key.to_sym][:type]

        if type == :boolean
          value = (value == 'true' || value == '1')
        elsif type == :integer
          value = value.to_i_safe
        end

        [key, value]
      end].compact
    end

    # Calls update_attributes on a given model and (if sucessful) saves an AuditEntry
    # with a record of all changed fields to the given Incident.
    # Call with ready_to_save=false to run validation but not save the AuditEntry.
    # Returns true if changes were saved, false if they failed to save.
    def save_and_audit(model, attributes, ready_to_save = true)
      # Save existing model state.
      old_values = Hash[attributes.keys.map { |k| [k, model.send(k)] }]
      is_new = !model.persisted?

      # Update the model and save the audit entry (if valid).
      if model.update_attributes(attributes) && ready_to_save
        build_audit_entry(model, attributes, old_values, is_new)
        true
      else
        false
      end
    end

  # End protected

  private

    def check_authorization
      if !@incident.authorized_to_view?(@current_user)
        raise BridgeExceptions::UnathorizedToView.new
      elsif !@incident.authorized_to_edit?(@current_user) && params[:action] != 'review'
        redirect_to review_incident_path(@incident)
      end
    end

    def build_audit_entry(model, attributes, old_values, is_new)
      entry = @incident.audit_entries.create(user: @current_user,
                                             page: model.model_name.human,
                                             is_new: is_new)

      attributes.each do |key, value|
        old_val = old_values[key].blank? ? '' : old_values[key].to_s
        new_val = value.blank? ? '' : value.to_s

        if new_val != old_val
          entry.save
          entry.changed_fields.create!(key: key, old_value: old_val, new_value: new_val)
        end
      end

      entry.destroy if entry.changed_fields.empty?  # We avoid creating empty audit entries.

      entry
    end

  # End private
end

# On DOJ infrastructure, we need to edit the returned URLs by hand, due
# to an issue in their proxy software. For non-DOJ infrastructure, we
# redirect as normal.
#
# This is kept in this file because it's super unintuitive that redirect_to
# would ever be overridden, so I don't want this code to be hidden. - EW
module ActionController
  # Handles special-case redirection on DOJ infrastructure.
  module Redirecting
    # Replaces the host part of 'url' with new_host
    def replace_url_host(url, new_host)
      protocol_end_idx = url.index('//') + 2
      host_end_idx = url.index('/', protocol_end_idx) || url.length
      new_host + url[host_end_idx..url.length]
    end

    # Assuming url is a full url (including http:// etc), replaces the host
    # with new_host.
    def redirect_to(options = {}, response_status = {}) #:doc:
      raise ActionControllerError.new("Cannot redirect to nil!") unless options
      raise AbstractController::DoubleRenderError if response_body

      self.status = _extract_redirect_to_status(options, response_status)
      location = _compute_redirect_to_location(request, options)
      if ENV['DOJ_HOST'].present?
        location = replace_url_host(location, ENV['DOJ_HOST'])
      end
      self.location = location

      escaped_location = ERB::Util.unwrapped_html_escape(location)
      self.response_body = "<html><body>You are being <a href=\"#{escaped_location}\">redirected</a>.</body></html>"
    end
  end
end
