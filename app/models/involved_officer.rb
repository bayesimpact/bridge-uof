# An Involved Officer form within an incident report.
class InvolvedOfficer < InvolvedPerson
  include Constants::InvolvedOfficer

  table name: :involved_officers

  before_save :maybe_clear_additional_questions

  field :age, :string
  field :officer_used_force, :boolean
  field :officer_used_force_reason, :array, default: []
  field :received_force, :boolean
  field :received_force_type, :array, default: []
  field :on_duty, :boolean
  field :dress, :string
  field :sworn_type, :string

  validates :age, inclusion: { in: AGES }
  validates :officer_used_force, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :officer_used_force_reason, presence: true, subset: { in: OFFICER_USED_FORCE_REASON_TYPES }, if: :officer_used_force
  validates :received_force, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :on_duty, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :dress, inclusion: { in: DRESS_TYPES }
  validates :sworn_type, inclusion: { in: SWORN_TYPES }

  with_options if: :received_force do
    validates :received_force_type, presence: true, subset: { in: RECEIVED_FORCE_TYPES }
    validates :received_force_location, presence: true, subset: { in: RECEIVED_FORCE_LOCATIONS }
  end

  private

    def maybe_clear_additional_questions
      unless received_force
        self[:received_force_type] = nil
        self[:received_force_location] = nil
      end

      self[:officer_used_force_reason] = nil unless officer_used_force

      super
    end
end
