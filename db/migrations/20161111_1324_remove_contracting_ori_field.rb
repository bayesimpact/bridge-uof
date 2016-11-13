# Migration to remove the 'ori' field for Incidents and
# rename the GeneralInfo 'contracting_for_ori' field to 'ori'.
class RemoveContractingOriField < DynamoDB::Migration::Unit
  def update
    logger = Logger.new(STDOUT)

    logger.info "Running migration #{self.class.name}:"

    incident_ids = Incident.all.map(&:id)
    logger.info "Updating #{incident_ids.length} Incident records ..."
    incident_ids.each do |id|
      client.update_item(
        table_name: "#{Dynamoid.config.namespace}_incidents",
        key: { 'id' => id },
        update_expression: "REMOVE ori"
      )
    end

    gis = GeneralInfo.all
    logger.info "Updating #{gis.length} GeneralInfo records ..."
    gis.each do |gi|
      # First, rename contracting_for_ori field to ori.
      begin
        client.update_item(
          table_name: "#{Dynamoid.config.namespace}_general_infos",
          key: { 'id' => gi.id },
          update_expression: "SET ori = contracting_for_ori REMOVE contracting_for_ori",
          condition_expression: "attribute_exists (contracting_for_ori)"
        )
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
        # Then, for any incidents who don't have an explicit ori defined,
        # take the user's ORI.
        logger.debug "  #{gi.id} has no contracting_for_ori - setting its ori to user's ori: #{gi.incident.user.ori}"
        gi.ori = gi.incident.user.ori
        gi.save!
      end
    end

    logger.info 'Done!'
    logger.info '================================'
  end
end
