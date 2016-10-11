# Validates that the incident ORI is allowed.
class OriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    ori = value || record.default_ori
    current_user = User.where(user_id: record.current_user_id).first

    if current_user.allowed_oris.exclude? ori
      record.errors[attribute] << "invalid ORI: #{ori}"
    end
  end
end
