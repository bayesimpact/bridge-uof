# An Involved Civilian form within an incident report.
class InvolvedCivilian < InvolvedPerson
  include Constants::InvolvedCivilian

  table name: :involved_civilians

  before_save :maybe_clear_additional_questions

  field :mental_status, :array
  field :assaulted_officer, :boolean
  field :highest_charge, :string
  field :crime_qualifier, :string
  field :perceived_armed, :boolean
  field :perceived_armed_weapon, :array
  field :firearm_type, :array
  field :resisted, :boolean
  field :resistance_type, :string
  field :received_force, :boolean
  field :received_force_type, :array
  field :custody_status, :string
  field :age, :string
  field :confirmed_armed, :boolean
  field :confirmed_armed_weapon, :array
  field :k12_type, :string

  validates :mental_status, presence: true, subset: { in: MENTAL_STATUSES }, civilian_mental_status: true
  validates :assaulted_officer, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :perceived_armed, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :resisted, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :received_force, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :custody_status, inclusion: { in: CUSTODY_STATUS_TYPES }

  validates :highest_charge, presence: true, if: :booked?
  validates :perceived_armed_weapon, presence: true, subset: { in: PERCEIVED_WEAPONS }, if: :perceived_armed
  validates :resistance_type, inclusion: { in: RESISTANCE_TYPES, allow_nil: true }, if: :resisted
  validates :k12_type, presence: true, inclusion: { in: K12_TYPE }, if: :k12_campus_incident?

  with_options if: :received_force do
    validates :received_force_type, presence: true, subset: { in: RECEIVED_FORCE_TYPES }
    validates :received_force_location, presence: true, subset: { in: RECEIVED_FORCE_LOCATIONS }
  end

  # For civilians that fled the scene, certain fields we will not collect
  # as the officer cannot be sure of what they saw of the person. Also
  # see the InvolvedPerson model.
  with_options unless: :fled? do
    validates :age, inclusion: { in: AGES }
    validates :confirmed_armed, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
    validates :confirmed_armed_weapon, presence: true, subset: { in: CONFIRMED_WEAPONS }, if: :confirmed_armed
    validates :firearm_type, presence: true, subset: { in: FIREARM_TYPES }, if: :firearm?
  end

  def k12_campus_incident?
    incident.try(:on_k12_campus)
  end

  def booked?
    CUSTODY_STATUSES_BOOKED.include? custody_status
  end

  def fled?
    custody_status == 'Fled'
  end

  def firearm?
    (confirmed_armed_weapon || []).include? WEAPON_FIREARM
  end

  def maybe_clear_additional_questions
    # Order of operations matters here

    FIELDS_NOT_COLLECTED_IF_FLED.each { |f| self[f] = nil } if fled?

    self[:perceived_armed_weapon] = nil unless perceived_armed
    self[:confirmed_armed_weapon] = nil unless confirmed_armed
    self[:firearm_type] = nil unless firearm?
    self[:resistance_type] = nil unless resisted
    self[:highest_charge] = nil unless booked?
    self[:crime_qualifier] = nil unless highest_charge.present?

    unless received_force
      self[:received_force_type] = nil
      self[:received_force_location] = nil
    end

    super
  end
end
