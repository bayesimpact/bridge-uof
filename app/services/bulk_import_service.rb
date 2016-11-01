# BulkImportService.import handles bulk import of incidents.
class BulkImportService
  def self.import(file, user)
    incidents = _parse_file(file)

    output = ["Uploading #{incidents.size} #{incidents.size == 1 ? 'incident' : 'incidents'} ..."]
    incidents.each_with_index do |incident, idx|
      output << _import_incident(incident, user, idx)
    end
    output
  rescue BridgeExceptions::ImportError => e
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
      raise BridgeExceptions::ImportError.new "Invalid file!\nAn error occurred while parsing #{filename}:\n    #{e.message}"
    end
  end

  def self._import_incident(incident, user, idx)
    incident = Incident.from_json(incident.to_json, user)
    "##{idx + 1}. Created incident #{incident.incident_id}."
  rescue BridgeExceptions::DeserializationError => e
    "##{idx + 1}. Error occurred!\n        #{e.message}"
  end
end
