# Branding-specific configuration code goes here.

branding = Rails.configuration.x.branding

branding.name = ENV["BRANDING"]
branding.incident_id_prefix = ENV["INCIDENT_ID_PREFIX"]

def branding.ursus?
  name == Constants::BRANDING_URSUS
end

def branding.whitelabel?
  name == Constants::BRANDING_WHITELABEL
end

# Validate presence of env vars.

if branding.incident_id_prefix.blank?
  raise 'Must set INCIDENT_ID_PREFIX env var.'
end

if Constants::AVAILABLE_BRANDINGS.exclude? branding.name
  raise "Must set BRANDING env variable to one of #{Constants::AVAILABLE_BRANDINGS} (currently it is '#{ENV['BRANDING']}')"
end
