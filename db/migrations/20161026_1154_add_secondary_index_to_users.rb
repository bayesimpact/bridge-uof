# Migration to add a secondary index to the Incidents table.
class AddSecondaryIndexToUsers < DynamoDB::Migration::Unit
  def update
    logger = Logger.new(STDOUT)

    logger.info "Running migration #{self.class.name}:"

    client.update_table(
      table_name: "#{Dynamoid.config.namespace}_users",
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
      provisioned_throughput: {
        read_capacity_units: Dynamoid::Config.read_capacity,
        write_capacity_units: Dynamoid::Config.write_capacity
      },
      global_secondary_index_updates: [
        {
          create: {
            index_name: Incident.indexes['ori'].name,
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

    logger.info 'Done!'
    logger.info '================================'
  end
end
