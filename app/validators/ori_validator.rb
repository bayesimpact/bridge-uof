# Validates that the incident ORI is allowed.
class OriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    user = record.incident.target.try(:user)

    if user && user.allowed_oris.exclude?(value)
      record.errors[attribute] << "invalid ORI: #{value}"
    end
  end
end
