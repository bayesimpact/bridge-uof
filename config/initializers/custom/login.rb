# Login-related initialization goes here.
#
# For development, we use the Devise gem for user authentication and
# account management. However, in production in the DOJ's AWS GovCloud,
# authentication will NOT be done with Devise.
# Our app will not do any authentication at all, actually.
# All requests will be proxied through a "Siteminder" auth server,
# which handles the login flow, and upon successful login, sets a cookie
# with the user's data (name, email, etc). All requests to Ursus will
# pass through this proxy, which will attach this cookie.
#
# The cookie is an encrypted JSON object, which has to be decrypted
# on our end before using. (See code for encryption mechanism).
# It follows Siteminder's Open Format Cookie standard
# (hence the cookie name, SMOFC).

AVAILABLE_LOGIN_MECHANISMS = %w(DEVISE SITEMINDER DEMO).freeze

login = Rails.configuration.x.login

def login.use_devise?
  ENV["LOGIN_MECHANISM"] == "DEVISE"
end

def login.use_siteminder?
  ENV["LOGIN_MECHANISM"] == "SITEMINDER"
end

def login.use_demo?
  ENV["LOGIN_MECHANISM"] == "DEMO"
end

# Ask @everett for these key values for your dev setup. They live in
# a google doc for now, findable on the internal wiki for this project.

login.siteminder_decrypt_key = ENV["SITEMINDER_DECRYPT_KEY"]
login.siteminder_decrypt_init_v = ENV["SITEMINDER_DECRYPT_INIT_V"]
login.siteminder_url_account = ENV["SITEMINDER_PATH_ACCOUNT"]
login.siteminder_url_logout = ENV["SITEMINDER_PATH_LOGOUT"]

# Ensure valid settings.

if AVAILABLE_LOGIN_MECHANISMS.exclude? ENV["LOGIN_MECHANISM"]
  raise BridgeExceptions::InvalidLoginMechanismError.new
end

if login.use_siteminder?
  if login.siteminder_decrypt_key.blank? || login.siteminder_decrypt_init_v.blank?
    raise 'Siteminder login improperly configured. Must set ' \
          'SITEMINDER_DECRYPT_KEY and SITEMINDER_DECRYPT_INIT_V env vars'
  end
  unless Rails.env.development? || Rails.env.test?
    if login.siteminder_url_account.blank? || login.siteminder_url_logout.blank?
      raise 'Siteminder account URLs not configured. Must set ' \
            'SITEMINDER_PATH_ACCOUNT and SITEMINDER_PATH_LOGOUT env vars'
    end
  end
end

# Users have different permissions based on their "role."
# The strings used to define each role are configurable

roles = Rails.configuration.x.roles
roles.user = (ENV["ROLE_USER"] || "user").downcase
roles.admin = (ENV["ROLE_ADMIN"] || "admin").downcase
roles.doj = (ENV["ROLE_DOJ"] || "doj").downcase
roles.all = [roles.user, roles.admin, roles.doj]
unless roles.all.uniq.length == 3
  raise "There should be 3 unique user roles. Environment was configured with only " \
        "#{roles.all.uniq.length}: #{roles.all.uniq}"
end
