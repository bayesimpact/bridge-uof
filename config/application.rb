require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ab71
  # Entry point for the Ursus application.
  class Application < Rails::Application
    config.autoload_paths += [
      Rails.root.join('lib'),
      Rails.root.join('app', 'models'),
      Rails.root.join('app', 'models', 'constants'),
      Rails.root.join('app', 'queries'),
      Rails.root.join('app', 'services'),
      Rails.root.join('app', 'validators')
    ]

    config.time_zone = 'Pacific Time (US & Canada)'
  end
end
