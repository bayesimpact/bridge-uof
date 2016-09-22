module Constants
  # Constants related to involved person models.
  module InvolvedPerson
    OTHER = 'Other'.freeze

    GENDERS = %w(Female Male Transgender).freeze

    NON_ASIAN_RACES = ['American Indian', 'Asian Indian', 'Black', 'Hispanic', 'White'].freeze

    ASIAN_RACE_STR = 'Asian / Pacific Islander'.freeze

    ASIAN_RACES = [
      'Cambodian', 'Chinese', 'Filipino', 'Guamanian',
      'Hawaiian', 'Japanese', 'Korean', 'Laotian', 'Samoan', 'Vietnamese',
      'Other Asian', 'Other Pacific Islander'
    ].freeze

    RACES = (NON_ASIAN_RACES + [ASIAN_RACE_STR, OTHER]).freeze

    MULTIRACIAL = 'Multiracial**'.freeze

    RECEIVED_FORCE_LOCATIONS = [
      '(Not applicable)', 'Head', 'Neck/throat', 'Front upper torso/chest',
      'Rear upper torso/back', 'Front lower torso/abdomen', 'Rear lower torso/back',
      'Front below waist/groin area', 'Rear below waist/buttocks',
      'Arms/hands ', 'Front legs/feet', 'Rear legs'
    ].freeze

    INJURY_LEVELS = ['Injury', 'Serious bodily injury', 'Death'].freeze

    INJURY_TYPES = [
      'Unconscious', 'Contusion', 'Concussion', 'Bone fracture',
      'Internal injury', 'Abrasion/Laceration', 'Obvious disfigurement',
      'Gunshot wound', 'Stabbing wound'
    ].freeze

    MEDICAL_AID = [
      'No medical assistance or refused assistance',
      'Medical assistance - treated on scene',
      'Medical assistance - treated at facility and released',
      'Admitted to hospital - precautionary measure only',
      'Admitted to hospital - critical injuries',
      'Admitted to hospital - other circumstance'
    ].freeze

    DISPLAY_FIELDS = [
      :received_force, :type_of_force_used, :received_force_location, :gender, :age, :display_race,
      :injured, :injury_level, :medical_aid, :injury_type, :injury_from_preexisting_condition
    ].freeze

    FBI_FIELDS = [:received_force, :type_of_force_used, :gender, :age, :display_race, :injury_type].freeze

    CUSTOM_LABELS_FOR_REVIEW = {
      display_race: "Race",
      injured: "Injured?",
      injury_from_preexisting_condition: "Injury from a pre-existing condition?"
    }.freeze
  end
end
