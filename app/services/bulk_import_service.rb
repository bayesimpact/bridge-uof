# BulkImportService.import handles bulk import of incidents.
class BulkImportService
  def self.import(file, user)
    incidents = _parse_file(file)

    output = ["Uploading #{incidents.size} #{incidents.size == 1 ? 'incident' : 'incidents'} ..."]
    incidents.each_with_index do |incident_hash, idx|
      output << _import_incident(incident_hash, user, idx)
    end
    output
  rescue BridgeExceptions::BulkUploadError => e
    e.message.split("\n")
  end

  # "Private methods"

  # Parse a JSON or XML file into an array of hashes representing incidents.
  def self._parse_file(file)
    filename = file.original_filename
    contents = file.read

    begin
      # Parse as JSON by default, but parse as XML if the extension is '.xml'.
      if filename.end_with?('.xml')
        Hash.from_xml(contents)['incidents']
      else
        JSON.parse(contents)
      end
    rescue JSON::ParserError, REXML::ParseException => e
      msg = "Invalid file!\nAn error occurred while parsing #{filename}:\n    #{e.message}"
      raise BridgeExceptions::BulkUploadError.new(msg)
    end
  end

  def self._import_incident(incident_hash, user, idx)
    incident = Incident.from_hash(incident_hash, user)
    "##{idx + 1}. Created incident #{incident.incident_id}."
  rescue BridgeExceptions::DeserializationError => e
    "##{idx + 1}. Error occurred!\n        #{e.message}"
  end
end
