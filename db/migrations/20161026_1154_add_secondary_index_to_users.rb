# Migration to add a secondary index to the Incidents table.
class AddSecondaryIndexToUsers < DynamoDB::Migration::Unit
  def update
    logger = Logger.new(STDOUT)

    logger.info "Running migration #{self.class.name}:"

    table_name = "#{Dynamoid.config.namespace}_users"
    index_name = User.indexes['ori'].name
    existing_indexes = client.describe_table(table_name: table_name).table
                             .global_secondary_indexes
                             .flat_map(&:index_name)

    if existing_indexes.include? index_name
      logger.info "Index #{index_name} already exists!"
    else
      logger.info "Creating index #{index_name} ..."
      client.update_table(
        table_name: table_name,
        attribute_definitions: [
          {
            attribute_name: "id",
            attribute_type: "S"
          },
          {
            attribute_name: "ori",
            attribute_type: "S"
          }
        ],
        global_secondary_index_updates: [
          {
            create: {
              index_name: index_name,
              key_schema: [
                {
                  attribute_name: "ori",
                  key_type: "HASH"
                }
              ],
              projection: {
                projection_type: "ALL",
                non_key_attributes: []
              },
              provisioned_throughput: {
                read_capacity_units: Dynamoid::Config.read_capacity,
                write_capacity_units: Dynamoid::Config.write_capacity
              }
            }
          }
        ]
      )
    end

    logger.info 'Done!'
    logger.info '================================'
  end
end
