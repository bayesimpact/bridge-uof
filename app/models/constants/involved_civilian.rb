module Constants
  # Constants related to the InvolvedCivilian model.
  module InvolvedCivilian
    AGES = [
      '0-9', '10-17', '18-20', '21-25', '26-30', '31-35', '36-40', '41-45', '46-50',
      '51-55', '56-60', '61-65', '66-70', '71-75', '76-80', '81-85', '86-90', '91-95', '96-100+'
    ].freeze

    MENTAL_STATUSES = [
      'Signs of mental disability', 'Signs of developmental disability',
      'Signs of physical disability', 'Signs of drug impairment', 'Signs of alcohol impairment', 'None'
    ].freeze

    WEAPON_FIREARM = 'Firearm'.freeze

    PERCEIVED_WEAPONS = [
      WEAPON_FIREARM, 'Knife, blade, or stabbing instrument', 'Other dangerous weapon', 'Unknown'
    ].freeze

    CONFIRMED_WEAPONS = [
      WEAPON_FIREARM, 'Firearm replica', 'Knife, blade, or stabbing instrument', 'Other dangerous weapon'
    ].freeze

    RESISTANCE_TYPES = ['Passive non-compliance', 'Resistance', 'Assaultive', 'Life-threatening'].freeze

    RECEIVED_FORCE_TYPES = [
      'Carotid restraint control hold', 'Other control hold/takedown',
      'Other physical contact (Use of hands, fists, feet, etc)', 'Officer vehicle contact',
      'Blunt / impact weapon', 'Chemical spray (e.g. OC/CS)', 'Electronic control device',
      'Impact projectile', 'Knife, blade, or stabbing instrument', 'Threat of firearm',
      'Discharge of firearm (miss)', 'Discharge of firearm (hit)', 'Other dangerous weapon', 'K-9 contact'
    ].freeze

    FIREARM_TYPES = ['Handgun', 'Rifle', 'Shotgun', 'Other firearm'].freeze

    CUSTODY_STATUS_TYPES = ['Cited and released', 'In custody', 'Fled', 'Deceased', 'None of these'].freeze

    CUSTODY_STATUSES_BOOKED = ['Cited and released', 'In custody'].freeze

    DISPLAY_FIELDS = ([
      :assaulted_officer, :custody_status, :highest_charge, :crime_qualifier, :perceived_armed,
      :perceived_armed_weapon, :confirmed_armed, :confirmed_armed_weapon, :firearm_type, :resisted, :resistance_type
    ] + Constants::InvolvedPerson::DISPLAY_FIELDS).freeze

    FBI_FIELDS = ([
      :perceived_armed, :perceived_armed_weapon, :confirmed_armed,
      :confirmed_armed_weapon, :resisted, :resistance_type, :mental_status
    ] + Constants::InvolvedPerson::FBI_FIELDS).freeze

    CUSTOM_LABELS_FOR_REVIEW = {
      assaulted_officer: "Civilian assaulted officer?",
      arrested: "Arrested or in custody?",
      perceived_armed: "Perceived armed?",
      confirmed_armed: "Confirmed armed?",
      resisted: "Resisted?",
      received_force: "Force used by an officer?"
    }.merge(Constants::InvolvedPerson::CUSTOM_LABELS_FOR_REVIEW).freeze

    # Only root questions. Sub-questions will be handled automatically.
    FIELDS_NOT_COLLECTED_IF_FLED = [
      :highest_charge, :crime_qualifier, :confirmed_armed, :age, :gender, :race, :injured
    ].freeze
  end
end
