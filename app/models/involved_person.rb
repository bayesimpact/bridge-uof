# Base class for forms representing people involved in an incident.
class InvolvedPerson
  include Dynamoid::Document
  include AllowsPartialSave
  include Serializable
  include Constants::InvolvedPerson

  before_save :maybe_clear_additional_questions

  belongs_to :incident

  field :gender, :string
  field :race, :array
  field :asian_race, :array
  field :injured, :boolean
  field :injury_level, :string
  field :injury_type, :array
  field :medical_aid, :string
  field :injury_from_preexisting_condition, :boolean
  field :received_force_location, :array
  field :order_of_force_specified, :boolean
  field :order_of_force_str, :string

  # For civilians that fled the scene, certain fields we will not collect
  # as the officer cannot be sure of what they saw of the person. Also
  # see the InvolvedCivilian model.

  with_options unless: :fled? do
    validates :gender, inclusion: { in: GENDERS }
    validates :race, presence: true, subset: { in: RACES }
    validates :injured, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }

    validates :asian_race, presence: true, subset: { in: ASIAN_RACES }, if: :asian_race?
    validates :order_of_force_str, presence: true, if: :order_of_force_specified

    with_options if: :injured do
      validates :injury_level, inclusion: { in: INJURY_LEVELS }
      validates :injury_type, presence: true, subset: { in: INJURY_TYPES }
      validates :medical_aid, inclusion: { in: MEDICAL_AID }
      validates :injury_from_preexisting_condition, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
    end
  end

  def display_race
    race + (asian_race || [])
  end

  def type_of_force_used
    order_of_force_specified ? order_of_force_str : received_force_type
  end

  def seriously_injured_or_deceased?
    injured ? ['Serious bodily injury', 'Death'].include?(injury_level) : false
  end

  def self.sorted_persons(persons_association)
    persons_association.to_a.sort_by(&:created_at)
  end

  private

    def fled?
      false
    end

    def asian_race?
      race && race.include?(ASIAN_RACE_STR)
    end

    def maybe_clear_additional_questions
      unless injured
        self[:injury_level] = nil
        self[:injury_type] = nil
        self[:medical_aid] = nil
        self[:injury_from_preexisting_condition] = nil
      end

      self[:order_of_force_str] = nil unless order_of_force_specified
    end
end
