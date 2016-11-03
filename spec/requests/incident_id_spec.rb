require 'rails_helper'

describe '[Incident ID]', type: :request do
  let(:user) { build :dummy_user, ori: 'CA0123456' }

  before :all do
    Rails.configuration.x.branding.incident_id_prefix = 'PREFIX'
  end

  before :each do
    login user: user
  end

  it 'generates valid ID after general_info step' do
    create_partial_incident(:general)
    expect(Incident.first.incident_id).to be_blank
    answer_all_general_info submit: true

    i = Incident.first
    id = i.incident_id
    year = i.general_info.compute_datetime.year
    expect(id.to_s).not_to be nil
    expect(id.to_s[0..-4]).to eq("PREFIX-12-3456-#{year}-")

    expect(i.incident_id.prefix).to eq("PREFIX")
    expect(i.incident_id.county).to eq("12")
    expect(i.incident_id.agency).to eq("3456")
    expect(i.incident_id.year).to eq(year.to_s)
    expect(i.incident_id.code.length).to eq(Incident::INCIDENT_ID_CODE_LENGTH)
    i.incident_id.code.each_char { |c| expect(Incident::INCIDENT_ID_CODE_CHARS).to include c }
  end

  it 'generates unique IDs' do
    5.times { create_partial_incident(:civilians) }
    ids = Incident.all.map { |i| i.incident_id.to_s }
    expect(ids.sort).to eq(Set.new(ids).to_a.sort)
  end
end
