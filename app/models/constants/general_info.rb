module Constants
  # Constants related to the GeneralInfo model.
  module GeneralInfo
    DISPLAY_FIELDS = [
      :incident_id, :display_agency, :display_datetime, :address, :city, :state, :zip_code, :county,
      :multiple_locations, :on_k12_campus, :arrest_made, :crime_report_filed, :contact_reason,
      :in_custody_reason, :num_involved_civilians, :num_involved_officers
    ].freeze

    FBI_FIELDS = [
      :incident_date_str, :incident_time_str, :address, :city,
      :state, :zip_code, :county, :contact_reason
    ].freeze

    CUSTOM_LABELS_FOR_REVIEW = {
      incident_id: "Incident ID",
      display_agency: "Agency involved",
      display_datetime: "Incident time",
      num_involved_civilians: "Number of civilians involved",
      num_involved_officers: "Number of officers involved",
      multiple_locations: "Multiple incident locations?",
      on_k12_campus: "On a K-12 campus?",
      arrest_made: "Arrest made?",
      crime_report_filed: "Crime report filed?"
    }.freeze

    CONTACT_REASON_IN_CUSTODY = 'In Custody Event'.freeze

    CONTACT_REASONS = [
      'Call for Service',
      CONTACT_REASON_IN_CUSTODY,
      'Consensual Encounter / Public Contact / Flag Down',
      'Vehicle / Bike / Pedestrian Stop',
      'Pre-Planned Activity (arrest/search warrant, parole/probation search)',
      'Welfare Check',
      'Crime in Progress / Investigating Suspicious Persons or Circumstances',
      'Civil Assembly',
      'Civil Disorder',
      'Ambush - No warning'
    ].freeze

    IN_CUSTODY_REASONS = [
      'In Transit', 'Awaiting Booking', 'Booked - No Charges Filed',
      'Booked - Awaiting Trial', 'Out to Court', 'Sentenced', 'Other'
    ].freeze

    STATES = %w(AL AK AZ AR CA CZ CO CT DE DC FL GA GU HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO
                MT NE NV NH NJ NM NY NC ND OH OK OR PA PR RI SC SD TN TX UT VT VI VA WA WV WI WY).freeze
  end
end
