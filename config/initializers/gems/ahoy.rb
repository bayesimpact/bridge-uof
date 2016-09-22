# Ahoy tracks visits and user events and stores them in our DynamoDB instance.
# The procedures for tracking visits and events (controller actions) are a little different:
# 1. To track visits, ahoy.js fires requests to /ahoy/visits, and Ahoy::VisitsController calls Store#track_visit.
# 2. To track actions, we define an after_action trigger in ApplicationController that calls Store#track_event.
module Ahoy
  # Our Dynamoid store of visits and events.
  # Because Dynamoid support is not built into Ahoy, we have to specify custom
  # #track_visit and #track_event methods.
  # TODO: At some point, add Dynamoid functionality to the Ahoy gem itself.
  class Store < Ahoy::Stores::BaseStore
    def track_visit(options)
      return if ENV['DISABLE_TRACKING'] == 'true'

      @visit = Visit.new(id: ahoy.visit_id, visitor_id: ahoy.visitor_id, started_at: options[:started_at])
      @visit.user = user if user
      set_visit_properties(visit)

      yield(visit) if block_given?

      begin
        visit.save!
        geocode(visit)
      rescue *unique_exception_classes
        logger.debug("Ahoy::Store.track_visit: Uniqueness violation")
      end
    end

    def track_event(name, properties, options)
      return if ENV['DISABLE_TRACKING'] == 'true'

      event = Event.new(id: options[:id], name: name, properties: properties.to_json, time: options[:time])
      event.user = user if user
      event.visit = visit if visit

      yield(event) if block_given?

      begin
        event.save!
      rescue *unique_exception_classes
        logger.debug("Ahoy::Store.track_event: Uniqueness violation")
      end
    end

    def visit
      @visit ||= Visit.where(id: ahoy.visit_id).first if ahoy.visit_id
    end

    def user
      # Because we have a custom authentication mechanism, we need to
      # override Ahoy::Stores::BaseStore#user to retrieve @current_user.
      # (Note that Ahoy controllers don't fire any of the after_* and before_*
      #  triggers that other controllers do, so it is necessary to call
      #  #authenticate! manually if we're calling this from Ahoy::VisitsController.)
      controller.try(:authenticate!) unless controller.instance_variable_get('@current_user')
      controller.instance_variable_get('@current_user')
    end
  end
end
