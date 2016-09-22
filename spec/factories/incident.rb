FactoryGirl.define do
  factory :incident, class: Incident do
    transient do
      num_civilians 1
      num_officers  1
    end

    ori { build(:dummy_user).ori }

    user { User.find_by_user_id(build(:dummy_user).user_id) || create(:dummy_user) }

    after(:create) do |incident, e|  # e is the FactoryGirl evaluator (has access to transient attributes).
      incident.screener = create :screener

      incident.general_info = create(:general_info) do |g|
        g.update_attributes(
          num_involved_civilians: e.num_civilians,
          num_involved_officers: e.num_officers
        )
      end

      e.num_civilians.times do
        incident.involved_civilians << create(:involved_civilian)
      end

      e.num_officers.times do
        incident.involved_officers << create(:involved_officer)
      end

      incident.in_review!
    end
  end
end
