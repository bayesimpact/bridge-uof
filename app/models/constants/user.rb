module Constants
  # Constants related to the User model.
  module User
    SITEMINDER_KEY_MAPPING = {
      'givenname' => :first_name,
      'sn' => :last_name,
      'mail' => :email,
      'dojORI' => :ori,
      'dojagencyName' => :department,
      'SM_USERGROUPS' => :role,
      'SM_USERLOGINNAME' => :user_id
    }.freeze
    USER_FIELDS = SITEMINDER_KEY_MAPPING.values.freeze
  end
end
