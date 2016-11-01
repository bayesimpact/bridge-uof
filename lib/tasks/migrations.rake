require 'dynamodb/migration'

namespace :db do
  desc "Run all DynamoDB migrations"
  task migrate: :environment do
    aws_client = Dynamoid.adapter.adapter.client
    DynamoDB::Migration.run_all_migrations(
      client: aws_client,
      path: Rails.root.join('db/migrations'),
      migration_table_name: "#{Dynamoid.config.namespace}_migrations"
    )
  end
end
