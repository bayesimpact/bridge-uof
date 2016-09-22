# AWS-related configuration goes here.

Aws.config[:region] = ENV['AWS_REGION'] || 'us-west-1'

if ENV['USE_DEVELOPMENT_AWS_KEYS'] == 'true' && Rails.env != 'test'
  # Allow overriding of key settings, in case we need to run local dynamodb.
  aws_env_key = 'development'
else
  aws_env_key = Rails.env
end

creds = YAML.load(File.read(Rails.root.join('config', 'aws.yml')))
if creds.key?(aws_env_key)
  creds = creds[aws_env_key]
  Aws.config[:credentials] = Aws::Credentials.new(creds['access_key_id'], creds['secret_access_key'])
  Aws.config[:endpoint] = creds['endpoint']
else
  Aws.config[:credentials] = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
end
