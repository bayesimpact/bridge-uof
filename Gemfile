source 'https://rubygems.org'

ruby "2.2.3"

gem 'ahoy_matey'
gem 'aws-sdk', '~> 2'
gem 'bootstrap-sass', '~> 3.3'
gem 'chartkick'
gem 'coffee-rails', '~> 4.1.0'
gem 'devise', '~> 3.5'
gem 'dotenv-rails'
gem 'dynamoid', git: 'https://github.com/bayesimpact/Dynamoid.git'
gem 'dynamoid-devise'
gem 'es5-shim-rails'
gem 'factory_girl_rails', '~> 4.0'
gem 'font-awesome-rails', '~> 4.5'
gem 'gaffe'
gem 'geocomplete_rails'
gem 'jquery-rails'
gem 'jquery-timepicker-addon-rails'
gem 'jquery-ui-rails', '~> 5.0'
gem 'orm_adapter-dynamoid', git: 'https://github.com/bayesimpact/orm_adapter-dynamoid.git'
gem 'puma'
gem 'rails', '4.2.3'
gem 'request_store'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

group :test do
  gem 'capybara', '~> 2.7'
  gem 'capybara-slow_finder_errors'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'rspec-rails', '~> 3.4'
  gem 'rspec-retry'
  gem 'timecop'
end

group :development do
  gem 'launchy'
  gem 'quiet_assets'  # Don't clutter the logs with GET calls to assets.
end

group :development, :test do
  gem 'byebug'  # Call 'byebug' anywhere in the code to stop execution and get a debugger console.
  gem 'spring'  # Spring speeds up development by keeping your application running in the background.
end
