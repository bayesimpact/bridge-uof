FactoryGirl.define do
  factory :dummy_user, class: User do
    first_name 'Dummy'
    last_name 'User'
    email 'test@example.com'
    password 'password' if Rails.configuration.x.login.use_devise?
    ori 'ORI01234'
    role Rails.configuration.x.roles.admin
    department 'Foo Police Department'
    user_id 'some_user_id_123'
  end
end
