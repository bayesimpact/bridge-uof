FactoryGirl.define do
  factory :additional_submission_information, aliases: [:asi] do
    ori 'CA00227777'
    submission_year Time.last_year.to_s
    k9_officer_severely_injured_count 1
    non_sworn_uniformed_injured_or_killed_count 2
    civilians_injured_or_killed_by_non_sworn_uniformed_count 3
  end
end
