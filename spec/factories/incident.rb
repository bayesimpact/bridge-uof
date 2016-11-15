FactoryGirl.define do
  factory :incident do
    transient do
      user_id       { build(:dummy_user).user_id }
      num_civilians 1
      num_officers  1
      submit        true
      stop_step     nil
      ori           nil
    end

    status { 'in_review' if submit }

    user { User.find_by_user_id(user_id) || create(:dummy_user) }
    screener
    general_info { create(:general_info, num_involved_civilians: num_civilians, num_involved_officers: num_officers, ori: (ori || user.ori)) }

    # e is the FactoryGirl evaluator (has access to transient attributes).
    after(:create) do |incident, e|
      unless e.stop_step == :officers
        e.num_officers.times do
          incident.involved_officers << create(:involved_officer)
        end
      end

      unless e.stop_step == :civilians
        e.num_civilians.times do
          incident.involved_civilians << create(:involved_civilian)
        end
      end
    end
  end
end
