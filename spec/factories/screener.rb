FactoryGirl.define do
  factory :screener do
    id { SecureRandom.uuid }
    multiple_agencies false
    shots_fired true
  end
end
