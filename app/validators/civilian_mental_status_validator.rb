# Validates that a mental status list doesn't include both 'None' and something else.
class CivilianMentalStatusValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && value.include?('None') && value.length >= 2
      record.errors[attribute] << "cannot specify both 'None' and another value"
    end
  end
end
