FactoryGirl.define do
  factory :involved_officer, class: InvolvedOfficer do
    id { SecureRandom.uuid }
    officer_used_force false
    officer_used_force_reason ['To effect arrest']
    injured false
    received_force true
    received_force_type ['Blunt / impact weapon']
    received_force_location ['Head']
    on_duty true
    dress 'Tactical'
    sworn_type 'Sworn officer'
    age '21-25'
    race { InvolvedPerson::RACES.sample_one_or_two_elements }
    asian_race { race.include?(InvolvedPerson::ASIAN_RACE_STR) ? InvolvedPerson::ASIAN_RACES.sample_one_or_two_elements : nil }
    gender 'Male'
  end
end
