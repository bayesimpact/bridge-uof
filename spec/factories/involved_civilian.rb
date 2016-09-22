FactoryGirl.define do
  factory :involved_civilian, class: InvolvedCivilian do
    id { SecureRandom.uuid }
    assaulted_officer false
    perceived_armed false
    confirmed_armed { [true, false].sample }
    confirmed_armed_weapon { confirmed_armed ? InvolvedCivilian::CONFIRMED_WEAPONS.sample_one_or_two_elements : nil }
    firearm_type { confirmed_armed_weapon ? InvolvedCivilian::FIREARM_TYPES.sample_one_or_two_elements : nil }
    resisted false
    received_force true
    received_force_type { InvolvedCivilian::RECEIVED_FORCE_TYPES.sample_one_or_two_elements }
    received_force_location ['Head']
    injured false
    custody_status 'In custody'
    mental_status ['None']
    highest_charge 'Some charge'
    age '21-25'
    race { InvolvedPerson::RACES.sample_one_or_two_elements }
    asian_race { race.include?(InvolvedPerson::ASIAN_RACE_STR) ? InvolvedPerson::ASIAN_RACES.sample_one_or_two_elements : nil }
    gender 'Male'
  end
end
