require 'rails_helper'

describe '[Incident serialization and bulk upload]', type: :request do
  before :each do
    login
    @user = User.first
    stub_const('Constants::DEPARTMENT_BY_ORI', @user.ori => @user.department)

    # Serialize in the `before :each` so that we can play with this valid json in all of the tests.
    create_complete_incident
    @valid_json = Incident.first.to_json

    # Remove the original incident from the DB to avoid ID collisions.
    @original_incident = Incident.first
    @original_incident.destroy
  end

  it 'serializes and deserializes incidents properly' do
    deserialized_incident = Incident.from_json(@valid_json, @user)

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

    expect { Incident.from_json(@invalid_json, @user) }.to raise_error do |error|
      expect(error.message).to include('Validation failed')
      expect(error.message).to include('[Screener] Shots fired Can\'t be blank')
      expect(error.message).to include("[General info] Incident date str invalid year")
      expect(error.message).to include('[Involved civilian] Gender is not included in the list')
    end
  end

  it 'cries on broken JSON' do
    straight_up_broken_json = @valid_json[5..-1]
    expect { Incident.from_json(straight_up_broken_json, @user) }.to raise_error("Parsing error: invalid JSON")

    json_with_missing_fields = {
      "ori" => @user.ori,
      "screener" => JSON.parse(@valid_json)['screener']
    }.to_json
    expect { Incident.from_json(json_with_missing_fields, @user) }.to raise_error("Parsing error: missing section: general_info")

    json_with_extra_garbage = @valid_json.sub('"shots_fired":"t"', '"shots_fired":"t","secondary_agency":"t"')
    expect { Incident.from_json(json_with_extra_garbage, @user) }.to raise_error("Parsing error: unexpected field: secondary_agency in Screener")
  end

  it 'can create an incident via JSON upload', driver: :poltergeist do
    # TODO: Test that ORI validation is enabled in devise/siteminder mode and disabled in demo mode.

    file = Tempfile.new(['incident', '.json'])
    file.write("[ #{@valid_json} ]")
    file.close

    visit 'incidents/upload'
    execute_script('$("input[type=file]").show().appendTo("form");')
    attach_file('file', file.path)

    expect(page).to have_content('Uploading 1 incident ...')
    expect(page).to have_content('Created incident')
    expect(Incident.count).to eq(1)
    expect(Incident.first).to be_valid
    expect(Incident.first).to be_approved
  end

  it 'can create an incident via XML upload', driver: :poltergeist do
    # TODO: Test that ORI validation is enabled in devise/siteminder mode and disabled in demo mode.

    valid_xml = { incident: JSON.parse(@valid_json) }.to_xml(root: 'incidents')
                                                     .sub('<incidents>', '<incidents type="array">')
    puts valid_xml

    file = Tempfile.new(['incident', '.xml'])
    file.write("[ #{valid_xml} ]")
    file.close

    visit 'incidents/upload'
    execute_script('$("input[type=file]").show().appendTo("form");')
    attach_file('file', file.path)

    expect(page).to have_content('Uploading 1 incident ...')
    expect(page).to have_content('Created incident')
    expect(Incident.count).to eq(1)
    expect(Incident.first).to be_valid
    expect(Incident.first).to be_in_review
  end
end
