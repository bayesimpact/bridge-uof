# Validates that the incident ORI is allowed.
class OriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    ori = value || record.incident.target.try(:ori)
    user = record.incident.target.try(:user)

    if user && user.allowed_oris.exclude?(ori)
      record.errors[attribute] << "invalid ORI: #{ori}"
    end
  end
end
