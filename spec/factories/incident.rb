FactoryGirl.define do
  factory :incident do
    status 'in_review'
    user { User.find_by_user_id(build(:dummy_user).user_id) || create(:dummy_user) }
    screener
    general_info
    association :involved_civilians, factory: :involved_civilian
    association :involved_officers, factory: :involved_officer
  end
end
