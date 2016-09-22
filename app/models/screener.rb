# A Screener form within an incident report.
class Screener
  include Dynamoid::Document
  include AllowsPartialSave
  include Serializable

  belongs_to :incident

  field :multiple_agencies, :boolean
  field :shots_fired, :boolean
  field :officer_used_force, :boolean
  field :civilian_seriously_injured, :boolean
  field :civilian_used_force, :boolean
  field :officer_seriously_injured, :boolean

  validates :multiple_agencies, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }
  validates :shots_fired, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }

  with_options unless: :shots_fired do
    validates :civilian_used_force, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }

    validates :officer_used_force, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD }

    validates :officer_seriously_injured, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD },
                                          if: :civilian_used_force

    validates :civilian_seriously_injured, inclusion: { in: [true, false], message: Constants::ERROR_BLANK_FIELD },
                                           if: :officer_used_force
  end

  before_validation :maybe_clear_additional_questions

  def maybe_clear_additional_questions
    self[:officer_used_force] = nil if shots_fired
    self[:civilian_used_force] = nil if shots_fired
    self[:civilian_seriously_injured] = nil unless officer_used_force
    self[:officer_seriously_injured] = nil unless civilian_used_force
  end

  def civilian_injured_by_force?
    officer_used_force && civilian_seriously_injured
  end

  def officer_injured_by_force?
    civilian_used_force && officer_seriously_injured
  end

  def forms_necessary?
    [shots_fired, officer_injured_by_force?, civilian_injured_by_force?].any?
  end
end
