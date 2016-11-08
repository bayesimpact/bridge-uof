require 'rails_helper'

describe '[Incident serialization and bulk upload]', type: :request do
  let(:incident) { create(:incident, &:destroy) }
  let(:valid_json) { incident.to_hash.to_json }
  let(:deserialized_incident) { Incident.from_hash(JSON.parse(valid_json), user) }
  let(:user) { User.first }

  before :each do
    login
  end

  it 'serializes and deserializes incidents properly' do
    expect(deserialized_incident).to be(incident)
    expect(deserialized_incident.audit_entries.count).to eq(1)
    expect(deserialized_incident.audit_entries[0].user.id).to eq(user.id)
    expect(deserialized_incident.audit_entries[0].custom_text).to eq('imported this incident')
  end

  it 'maintains a 2-way association between Incident and GeneralInfo for factory-created and deserialized incidents' do
    expect(incident.general_info.incident.target).to be_present
    expect(deserialized_incident.general_info.incident.target).to be_present

    # If one of the incidents is incomplete, uncomment to diagnose:
    # p incident.general_info.incident.next_step
    # p deserialized_incident.general_info.incident.next_step

    expect(incident.general_info.incident.target).to be(deserialized_incident.general_info.incident.target)
  end

  it 'throws descriptive errors on validation failure' do
    # This JSON is valid except for three errors:
    #   1. screener.shots_fired = null
    #   2. general_info.incident_date_str is in the far future
    #   3. involved_civilians[0].gender = 'Alien'
    invalid_json = valid_json.sub('"shots_fired":"t"', '"shots_fired":null')
                             .sub(%r{"incident_date_str":"[\d\/]*"}, '"incident_date_str":"06/06/9999"')
                             .sub('"gender":"Male"', '"gender":"Alien"')

    expect { Incident.from_hash(JSON.parse(invalid_json), user) }.to raise_error do |error|
      expect(error.message).to include('Validation failed')
      expect(error.message).to include('[Screener] Shots fired Can\'t be blank')
      expect(error.message).to include("[General info] Incident date str invalid year")
      expect(error.message).to include('[Involved civilian] Gender is not included in the list')
    end
  end

  it 'cries when given incorrect data' do
    # Note that, while this test uses JSON clarity for simplicity,
    # the same results hold for XML import, since the method being tested,
    # Incident.from_hash, operates on hashes that have already been
    # parsed from JSON or XML.

    json_with_missing_fields = {
      "ori" => user.ori,
      "screener" => JSON.parse(valid_json)['screener']
    }.to_json
    expect { Incident.from_hash(JSON.parse(json_with_missing_fields), user) }.to raise_error("Parsing error: missing section: general_info")

    json_with_extra_garbage = valid_json.sub('"shots_fired":"t"', '"shots_fired":"t","secondary_agency":"t"')
    expect { Incident.from_hash(JSON.parse(json_with_extra_garbage), user) }.to raise_error("Parsing error: unexpected field: secondary_agency in Screener")

    # Make sure that nothing got saved into the DB from the broken data.

    expect(Incident.count).to eq(0)
    expect(Screener.count).to eq(0)
    expect(GeneralInfo.count).to eq(0)
    expect(InvolvedCivilian.count).to eq(0)
    expect(InvolvedOfficer.count).to eq(0)
  end

  describe '[Bulk upload]', driver: :poltergeist do
    let(:valid_xml) do
      { incident: JSON.parse(valid_json) }.to_xml(root: 'incidents')
                                          .sub('<incidents>', '<incidents type="array">')
    end

    it 'can create an incident via JSON upload' do
      json_file = Tempfile.new(['incident', '.json'])
      json_file.write("[ #{valid_json} ]")
      json_file.close

      visit 'incidents/upload'
      execute_script('$("input[type=file]").show().appendTo("form");')
      attach_file('file', json_file.path)

      expect(page).to have_content('Uploading 1 incident ...')
      expect(page).to have_content('Created incident')
      expect(Incident.count).to eq(1)
      expect(Incident.first).to be_valid
      expect(Incident.first).to be_approved
    end

    it 'displays an error message on broken JSON' do
      json_file = Tempfile.new(['incident', '.json'])
      json_file.write("[ #{valid_json} ]blah")
      json_file.close

      visit 'incidents/upload'
      execute_script('$("input[type=file]").show().appendTo("form");')
      attach_file('file', json_file.path)

      expect(page).to have_content('Invalid file!')
      expect(Incident.count).to eq(0)
    end

    it 'can create an incident via XML upload' do
      xml_file = Tempfile.new(['incident', '.xml'])
      xml_file.write(valid_xml)
      xml_file.close

      visit 'incidents/upload'
      execute_script('$("input[type=file]").show().appendTo("form");')
      attach_file('file', xml_file.path)

      expect(page).to have_content('Uploading 1 incident ...')
      expect(page).to have_content('Created incident')
      expect(Incident.count).to eq(1)
      expect(Incident.first).to be_valid
      expect(Incident.first).to be_approved
    end

    it 'displays an error message on broken XML' do
      xml_file = Tempfile.new(['incident', '.xml'])
      xml_file.write("#{valid_xml}<blah>")
      xml_file.close

      visit 'incidents/upload'
      execute_script('$("input[type=file]").show().appendTo("form");')
      attach_file('file', xml_file.path)

      expect(page).to have_content('Invalid file!')
      expect(Incident.count).to eq(0)
    end
  end
end
