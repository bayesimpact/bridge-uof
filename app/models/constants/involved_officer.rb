module Constants
  # Constants related to the InvolvedOfficer model.
  module InvolvedOfficer
    AGES = [
      '18-20', '21-25', '26-30', '31-35', '36-40', '41-45', '46-50', '51-55',
      '56-60', '61-65', '66-70', '71-75', '76-80', '81-85', '86-90', '91-95', '96-100+'
    ].freeze

    DRESS_TYPES = ['Patrol Uniform', 'Tactical', 'Utility', 'Plainclothes'].freeze

    RECEIVED_FORCE_TYPES = [
      'Civilian physical contact', 'Civilian vehicle contact', 'Blunt / impact weapon',
      'Chemical spray (e.g. OC/CS)', 'Electronic control device', 'Impact projectile',
      'Knife, blade, or stabbing instrument', 'Threat of firearm', 'Discharge of firearm (miss)',
      'Discharge of firearm (hit)', 'Other dangerous weapon', 'Animal'
    ].freeze

    OFFICER_USED_FORCE_REASON_TYPES = ['To effect arrest', 'To prevent escape', 'To overcome resistance'].freeze

    DISPLAY_FIELDS = ([
      :officer_used_force, :officer_used_force_reason, :on_duty, :dress
    ] + Constants::InvolvedPerson::DISPLAY_FIELDS).freeze

    FBI_FIELDS = Constants::InvolvedPerson::FBI_FIELDS.freeze

    CUSTOM_LABELS_FOR_REVIEW = {
      officer_used_force: "Officer used force against civilian(s)?",
      received_force: "Officer assaulted by civilian(s)?",
      on_duty: "On duty?",
    }.merge(Constants::InvolvedPerson::CUSTOM_LABELS_FOR_REVIEW).freeze
  end
end
