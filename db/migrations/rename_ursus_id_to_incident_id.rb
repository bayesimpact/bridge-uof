# Migration to rename the 'ursus_id' field to 'incident_id' for Incidents.
class RenameUrsusIdToIncidentId < DynamoDB::Migration::Unit
  def update
    logger = Logger.new(STDOUT)

    logger.info "Running migration #{self.class.name}:"

    incident_ids = Incident.all.map(&:id)
    logger.info "Updating #{incident_ids.length} Incident records ..."
    incident_ids.each do |id|
      begin
        client.update_item(
          table_name: "#{Dynamoid.config.namespace}_incidents",
          key: { 'id' => id },
          update_expression: "SET incident_id_str = ursus_id_str REMOVE ursus_id_str",
          condition_expression: "attribute_exists (ursus_id_str)"
        )
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
      end
    end

    logger.info 'Done!'
    logger.info '================================'
  end
end
