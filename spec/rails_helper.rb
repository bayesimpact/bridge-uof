# Start Rails application.
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production.
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Requires that depend on rails go here.
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'

# Configure Rspec.
RSpec.configure do |config|
  # Added manually

  FactoryGirl::SyntaxRunner.send(:include, Helpers)  # Allow spec helpers to be used in FactoryGirl factories.

  Ahoy.track_visits_immediately = true  # Enables us to test Ahoy visit tracking without AJAX.

  config.include FactoryGirl::Syntax::Methods
  config.include Capybara::DSL

  config.use_transactional_fixtures = false

  config.around(:each) do |example|
    begin
      example.run
    ensure
      # TODO: Move to database_cleaner so that it can handle dynamoid.
      Dynamoid.adapter.tables.each do |table_name|
        if table_name.starts_with?(Dynamoid::Config.namespace)
          Dynamoid.adapter.truncate(table_name)
        end
      end
    end
  end

  config.before(:suite) do
    # Mock DEPARTMENT_BY_ORI and CONTRACTING_ORIS for all tests.
    RSpec::Mocks.with_temporary_scope do
      Constants::DEPARTMENT_BY_ORI = {
        'ORI01234' => 'Foo Police Department',  # This is the ORI/dept of the User fixture.
        'PARENT_ORI' => 'PARENT_DEPT',
        'SUB_ORI' => 'SUB_DEPT'
      }.freeze
      Constants::CONTRACTING_ORIS = {
        'PARENT_ORI' => ['SUB_ORI']
      }.freeze
    end
  end

  # Auto-generated

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
