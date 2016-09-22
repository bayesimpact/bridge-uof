# BulkImportService.import_from_json handles bulk import of incidents.
class BulkImportService
  def self.import_from_json(file, user)
    begin
      incidents = JSON.parse(file.read)
    rescue JSON::ParserError => e
      filename = file.original_filename
      output = ["Invalid file!", "An error occurred while parsing #{filename}:", "    #{e.message}"]
    else
      output = ["Uploading #{incidents.size} #{incidents.size == 1 ? 'incident' : 'incidents'} ..."]
      incidents.each_with_index do |incident, idx|
        output << _import_incident(incident, user, idx)
      end
    end

    output
  end

  # "Private methods"

  def self._import_incident(incident, user, idx)
    incident = Incident.from_json(incident.to_json, user)
    "##{idx + 1}. Created incident #{incident.incident_id}."
  rescue BridgeExceptions::DeserializationError => e
    "##{idx + 1}. Error occurred!\n        #{e.message}"
  end
end
