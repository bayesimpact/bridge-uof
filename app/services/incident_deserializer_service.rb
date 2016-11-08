# IncidentDeserializerService.from_hash handles incident deserialization.
class IncidentDeserializerService
  def self.from_hash(hash, user)
    begin
      ori = Rails.configuration.x.login.use_demo? ? user.ori : hash['ori']  # Ignore 'ori' field in DEMO auth mode.
      screener = Screener.from_hash(hash.fetch('screener'))
      general_info = GeneralInfo.from_hash(hash.fetch('general_info'))
      involved_civilians = hash.fetch('involved_civilians').map { |c| InvolvedCivilian.from_hash(c) }
      involved_officers = hash.fetch('involved_officers').map { |c| InvolvedOfficer.from_hash(c) }
    rescue => e
      raise generate_nicer_parsing_exception_message(e)
    end

    validate_ori(user, ori)
    validate_steps(screener, general_info, involved_civilians, involved_officers)

    create_incident!(user, ori, screener, general_info, involved_civilians, involved_officers)
  rescue => e
    # If anything went wrong, clean up any persisted state if necessary,
    # then propagate the error.
    cleanup(screener, general_info, involved_civilians, involved_officers)
    raise e
  end

  # "Private methods"

  def self.generate_nicer_parsing_exception_message(e)
    case e.message
    when /key not found: \"(\w*)\"/
      # rubocop:disable Style/PerlBackrefs
      BridgeExceptions::DeserializationError.new("Parsing error: missing section: #{$1}")
      # rubocop:enable Style/PerlBackrefs
    else
      BridgeExceptions::DeserializationError.new("Parsing error: #{e.message}")
    end
  end

  def self.create_incident!(user, ori, screener, general_info, involved_civilians, involved_officers)
    incident = Incident.create(user: user, ori: ori)
    begin
      incident.screener = screener
      incident.general_info = general_info
      incident.involved_civilians = involved_civilians
      incident.involved_officers = involved_officers
      incident.audit_entries << AuditEntry.new(user: user, custom_text: 'imported this incident')
      incident.incident_id.generate!
      incident.update_attribute :status, :approved
      incident.save!
    rescue => e
      incident.destroy
      raise e
    end
  end

  def self.validate_ori(user, ori)
    unless user.allowed_oris.include?(ori)
      raise BridgeExceptions::DeserializationError.new "You are not allowed to submit for #{ori}. This is not your " \
                                                      "ORI, nor an ORI of any agency you contract for."
    end
  end

  def self.validate_steps(screener, general_info, involved_civilians, involved_officers)
    steps = [screener, general_info] + involved_civilians + involved_officers
    if steps.any?(&:invalid?)
      errors = steps.select(&:invalid?).flat_map do |step|
        step.errors.full_messages.map { |msg| "[#{step.model_name.human}] #{msg}" }
      end
      raise BridgeExceptions::DeserializationError.new("Validation failed: #{errors.join(', ')}")
    end
  end

  def self.cleanup(screener, general_info, involved_civilians, involved_officers)
    screener.delete if screener.present?
    general_info.delete if general_info.present?
    involved_civilians.each(&:delete) if involved_civilians.present?
    involved_officers.each(&:delete) if involved_officers.present?
  rescue => e
    # If something bad happens during cleanup, just log it and keep going.
    Rails.logger.error("Exception during IncidentDeserializerService#cleanup: #{e.message}")
  end
end
