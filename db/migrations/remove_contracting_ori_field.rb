# Migration to remove the 'ori' field for Incidents and
# rename the GeneralInfo 'contracting_for_ori' field to 'ori'.
class RemoveContractingOriField < DynamoDB::Migration::Unit
  def update
    logger = Logger.new(STDOUT)

    logger.info 'Running migration #{self.class.name}:'

    incident_ids = Incident.all.map(&:id)
    logger.info 'Updating #{incident_ids.length} Incident records ...'
    incident_ids.each do |id|
      client.update_item(
        table_name: "#{Dynamoid.config.namespace}_incidents",
        key: { 'id' => id },
        update_expression: "REMOVE ori"
      )
    end

    general_info_ids = GeneralInfo.all.map(&:id)
    logger.info 'Updating #{general_info_ids.length} GeneralInfo records ...'
    general_info_ids.each do |id|
      client.update_item(
        table_name: "#{Dynamoid.config.namespace}_general_infos",
        key: { 'id' => id },
        update_expression: "SET ori = contracting_for_ori REMOVE contracting_for_ori"
      )
    end

    logger.info 'Done!'
    logger.info '================================'
  end
end
