require 'rails_helper'

describe '[Incident serialization and bulk upload]', type: :request do
  before :each do
    login
    @user = User.first
    stub_const('Constants::DEPARTMENT_BY_ORI', @user.ori => @user.department)

    # Serialize in the `before :each` so that we can play with this valid json in all of the tests.
    create_complete_incident
    @valid_json = Incident.first.to_hash.to_json
    @valid_xml = { incident: JSON.parse(@valid_json) }.to_xml(root: 'incidents')
                                                      .sub('<incidents>', '<incidents type="array">')

    # Remove the original incident from the DB to avoid ID collisions.
    @original_incident = Incident.first
    @original_incident.destroy
  end

  it 'serializes and deserializes incidents properly' do
    deserialized_incident = Incident.from_hash(JSON.parse(@valid_json), @user)

    expect(deserialized_incident).to be(@original_incident)
    expect(deserialized_incident.audit_entries.count).to eq(1)
    expect(deserialized_incident.audit_entries[0].user.id).to eq(@user.id)
    expect(deserialized_incident.audit_entries[0].custom_text).to eq('imported this incident')
  end

  it 'throws descriptive errors on validation failure' do
    # This JSON is valid except for three errors:
    #   1. screener.shots_fired = null
    #   2. general_info.incident_date_str is in the far future
    #   3. involved_civilians[0].gender = 'Alien'
    @invalid_json = @valid_json.sub('"shots_fired":"t"', '"shots_fired":null')
                               .sub(%r{"incident_date_str":"[\d\/]*"}, '"incident_date_str":"06/06/9999"')
                               .sub('"gender":"Female"', '"gender":"Alien"')

    expect { Incident.from_hash(JSON.parse(@invalid_json), @user) }.to raise_error do |error|
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
      "ori" => @user.ori,
      "screener" => JSON.parse(@valid_json)['screener']
    }.to_json
    expect { Incident.from_hash(JSON.parse(json_with_missing_fields), @user) }.to raise_error("Parsing error: missing section: general_info")

    json_with_extra_garbage = @valid_json.sub('"shots_fired":"t"', '"shots_fired":"t","secondary_agency":"t"')
    expect { Incident.from_hash(JSON.parse(json_with_extra_garbage), @user) }.to raise_error("Parsing error: unexpected field: secondary_agency in Screener")
  end

  describe '[Bulk upload]', driver: :poltergeist do
    it 'can create an incident via JSON upload' do
      json_file = Tempfile.new(['incident', '.json'])
      json_file.write("[ #{@valid_json} ]")
      json_file.close

      visit 'incidents/upload'
      execute_script('$("input[type=file]").show().appendTo("form");')
      attach_file('file', json_file.path)

      expect(page).to have_content('Uploading 1 incident ...')
      expect(page).to have_content('Created incident')
      expect(Incident.count).to eq(1)
      expect(Incident.first).to be_valid
      expect(Incident.first).to be_in_review
    end

    it 'displays an error message on broken JSON' do
      json_file = Tempfile.new(['incident', '.json'])
      json_file.write("[ #{@valid_json} ]}")
      json_file.close

      visit 'incidents/upload'
      execute_script('$("input[type=file]").show().appendTo("form");')
      attach_file('file', json_file.path)

      expect(page).to have_content('Invalid file!')
      expect(Incident.count).to eq(0)
    end

    it 'can create an incident via XML upload' do
      @xml_file = Tempfile.new(['incident', '.xml'])
      @xml_file.write(@valid_xml)
      @xml_file.close

      visit 'incidents/upload'
      execute_script('$("input[type=file]").show().appendTo("form");')
      attach_file('file', @xml_file.path)

      expect(page).to have_content('Uploading 1 incident ...')
      expect(page).to have_content('Created incident')
      expect(Incident.count).to eq(1)
      expect(Incident.first).to be_valid
      expect(Incident.first).to be_in_review
    end

    it 'displays an error message on broken XML' do
      xml_file = Tempfile.new(['incident', '.xml'])
      xml_file.write("#{@valid_xml}<blah>")
      xml_file.close

      visit 'incidents/upload'
      execute_script('$("input[type=file]").show().appendTo("form");')
      attach_file('file', xml_file.path)

      expect(page).to have_content('Invalid file!')
      expect(Incident.count).to eq(0)
    end
  end
end
