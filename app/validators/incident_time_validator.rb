# Validates that a time is in the appropriate format.
class IncidentTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^(([01][0-9])|(2[0-3]))[0-5][0-9]$/i
      record.errors[attribute] << "must be 4 digits, between 0000 and 2359"
    end
  end
end
