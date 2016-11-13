# Renames several fields for InvolvedCivilians and InvolvedOfficers.
class InvolvedPersonCopyChanges < DynamoDB::Migration::Unit
  def update
    logger = Logger.new(STDOUT)

    logger.info "Running migration #{self.class.name}:"

    civilians = InvolvedCivilian.all
    logger.info "Updating #{civilians.length} InvolvedCivilian records ..."
    civilians.each do |civilian|
      if civilian.resistance_type == 'Resistance'
        civilian.resistance_type = 'Active resistance'
      end

      if civilian.custody_status == 'In custody'
        civilian.custody_status = 'In custody (other)'
      end

      civilian.save(validation: false)
    end

    officers = InvolvedOfficer.all
    logger.info "Updating #{officers.length} InvolvedOfficer records ..."
    officers.each do |officer|
      officer.officer_used_force_reason = officer.officer_used_force_reason.map do |reason|
        reason == 'To effect arrest' ? 'To effect arrest or take into custody' : reason
      end

      officer.save(validation: false)
    end

    logger.info 'Done!'
    logger.info '================================'
  end
end
