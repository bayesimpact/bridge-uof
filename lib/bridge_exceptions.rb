# Custom exceptions go here.
module BridgeExceptions
  class BulkUploadError < StandardError; end
  class DeserializationError < StandardError; end
  class IncidentIdCollisionError < StandardError; end
  class SiteminderAuthenticationError < StandardError; end
  class SiteminderCookieNotFoundError < StandardError; end
  class UnableToSubmitError < StandardError; end
  class UnathorizedToView < ActionController::BadRequest; end
  class UnimplementedError < StandardError; end

  # Custom exceptions with default messages go below.

  # Thrown when an invalid login mechanism is detected.
  class InvalidLoginMechanismError < StandardError
    def initialize(msg = "Need to set LOGIN_MECHANISM env variable to DEVISE, SITEMINDER, or DEMO " \
                         "(currently it is '#{ENV['LOGIN_MECHANISM']}')")
      super
    end
  end
end
