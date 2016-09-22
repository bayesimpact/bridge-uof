# IncidentStatsService.get_stats_for_incident handles per-incident statistics,
# returning a hash of different stats.
class IncidentStatsService
  def self.get_stats_for_incident(incident, opts)
    stats = {
      "Year" => incident.year,
      "Month" => incident.month,

      "Num Civilians" => incident.general_info.num_involved_civilians,
      "Num Officers" => incident.general_info.num_involved_officers,

      "Civilian Race" => array_to_str(incident.involved_civilians.map { |c| race_str(c) }),
      "Officer Race" => array_to_str(incident.involved_officers.map { |o| race_str(o) }),

      "Civilian Armed?" => array_to_str(incident.involved_civilians.map { |c| confirmed_armed_str(c) }),
      "Civilian Weapon" => array_to_str(incident.involved_civilians.map { |c| confirmed_weapon_str(c) }),
      "Officer Force Used" => array_to_str(incident.involved_civilians.map { |c| force_received_str(c) })
    }

    stats.except!("Year") if opts[:exclude_year]

    stats
  end

  # "Private methods"

  def self.array_to_str(array)
    if array.blank?
      Constants::NONE
    elsif array.to_set.count > 1
      Constants::VARIOUS
    else
      array.first
    end
  end

  def self.race_str(person)
    if person.race.blank?
      Constants::UNCONFIRMED_FLED
    elsif person.race.count > 1
      InvolvedPerson::MULTIRACIAL
    else
      person.race.first
    end
  end

  def self.confirmed_armed_str(civilian)
    if civilian.fled?
      Constants::UNCONFIRMED_FLED
    else
      civilian.confirmed_armed ? "Yes" : "No"
    end
  end

  def self.confirmed_weapon_str(civilian)
    if civilian.fled?
      Constants::UNCONFIRMED_FLED
    elsif civilian.confirmed_armed_weapon.blank?
      Constants::NONE
    elsif civilian.confirmed_armed_weapon.count > 1
      Constants::MULTIPLE
    else
      civilian.confirmed_armed_weapon.first
    end
  end

  def self.force_received_str(civilian)
    if civilian.received_force_type.blank?
      Constants::NONE
    elsif civilian.received_force_type.count > 1
      Constants::MULTIPLE
    else
      civilian.received_force_type.first
    end
  end
end
