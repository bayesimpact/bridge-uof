# Value object representing the Ursus ID of an incident.
class IncidentId
  delegate :to_s, :blank?, :present?, to: :id_string

  def initialize(incident)
    @incident = incident
  end

  def generate!
    return unless @incident.ori && @incident.year

    prefix = "#{Rails.configuration.x.branding.incident_id_prefix}" \
             "-#{@incident.ori[3..4]}-#{@incident.ori[5..-1]}-#{@incident.year}-"
    chars = Incident::INCIDENT_ID_CODE_CHARS

    5.tries(catching: BridgeExceptions::IncidentIdCollisionError) do
      try_id = prefix + (0...Incident::INCIDENT_ID_CODE_LENGTH).map { chars[rand(chars.length)] }.join

      unless @incident.update_attribute(:ursus_id_str, try_id)
        exception_msg = "Failed to generate a unique ID for this incident. Most recently tried #{try_id}"
        raise BridgeExceptions::IncidentIdCollisionError.new(exception_msg)
      end
    end
  end

  def prefix
    id_string.split('-')[0]
  end

  def county
    id_string.split('-')[1]
  end

  def agency
    id_string.split('-')[2]
  end

  def year
    id_string.split('-')[3]
  end

  def code
    id_string.split('-')[4]
  end

  private

    def id_string
      # TODO: Change the field name in the incident table from 'ursus_id_str' to 'id_str'.
      generate! unless @incident.ursus_id_str
      @incident.ursus_id_str
    end
end
