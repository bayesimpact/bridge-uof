# Migration to add a secondary index to the Incidents table.
class AddSecondaryIndexToIncidents < DynamoDB::Migration::Unit
  def update
    logger = Logger.new(STDOUT)

    logger.info "Running migration #{self.class.name}:"

    client.update_table(
      table_name: "#{Dynamoid.config.namespace}_incidents",
      attribute_definitions: [
        {
          attribute_name: "id",
          attribute_type: "S"
        },
        {
          attribute_name: "ursus_id_str",
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
            index_name: Incident.indexes['ursus_id_str'].name,
            key_schema: [
              {
                attribute_name: "ursus_id_str",
                key_type: "HASH"
              }
            ],
            projection: {
              projection_type: "INCLUDE",
              non_key_attributes: ["id"]
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
