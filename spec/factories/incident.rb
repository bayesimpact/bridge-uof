FactoryGirl.define do
  factory :incident, class: Incident do
    transient do
      user_id       { build(:dummy_user).user_id }
      num_civilians 1
      num_officers  1
      submit        true
      stop_step     nil
    end

    user { User.find_by_user_id(user_id) || create(:dummy_user) }

    after(:create) do |incident, e|  # e is the FactoryGirl evaluator (has access to transient attributes).
      incident.screener = create :screener

      incident.general_info = create(:general_info) do |g|
        g.update_attributes(
          num_involved_civilians: e.num_civilians,
          num_involved_officers: e.num_officers
        )
      end

      unless e.stop_step == :civilians
        e.num_civilians.times do
          incident.involved_civilians << create(:involved_civilian)
        end

        unless e.stop_step == :officers
          e.num_officers.times do
            incident.involved_officers << create(:involved_officer)
          end

          incident.in_review! if e.submit
        end
      end

      incident.general_info.incident = incident
      # All of the below lines are needed, or else the "2-way association" test fails. WTF
      incident.general_info.incident.target
      incident.general_info.incident.screener.target
      incident.general_info.incident.general_info.target
      incident.general_info.incident.involved_civilians.target
      incident.general_info.incident.involved_officers.target
    end
  end
end
