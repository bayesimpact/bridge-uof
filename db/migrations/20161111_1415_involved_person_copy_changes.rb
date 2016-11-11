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

      civilian.save!
    end

    officers = InvolvedOfficer.all
    logger.info "Updating #{officers.length} InvolvedOfficer records ..."
    officers.each do |officer|
      if officer.officer_used_force_reason == 'To effect arrest'
        officer.officer_used_force_reason = 'To effect arrest or take into custody'
      end

      officer.save!
    end

    logger.info 'Done!'
    logger.info '================================'
  end
end
