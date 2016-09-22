FactoryGirl.define do
  factory :screener, class: Screener do
    id { SecureRandom.uuid }
    multiple_agencies false
    shots_fired true
  end
end
