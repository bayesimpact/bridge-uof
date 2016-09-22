FactoryGirl.define do
  factory :general_info, class: GeneralInfo do
    id { SecureRandom.uuid }
    # Generate a random date in the past year.
    incident_date_str { rand(Date.civil(Time.current.year - 1, 1, 1)..Date.civil(Time.current.year - 1, 12, 31)).strftime('%m/%d/%Y') }
    incident_time_str '1400'
    address '123 Main Street'
    city 'San Francisco'
    state 'CA'
    zip_code '94123'
    county 'San Francisco County'
    multiple_locations false
    on_k12_campus false
    arrest_made false
    crime_report_filed false
    contact_reason GeneralInfo::CONTACT_REASONS[0]
    num_involved_civilians 1
    num_involved_officers 1
  end
end
