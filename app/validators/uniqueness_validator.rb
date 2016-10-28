# Validates that an attribute of the given object is unique -
# that is, no other instance of this model has that attribute value.
# Avoids a SCAN operation if possible by attempting a secondary index query.
class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(document, attribute, value)
    records = begin
      if document.class.indexed_hash_keys.include? attribute.to_s
        document.class.find_all_by_secondary_index(attribute => value)
      else
        document.class.where(attribute => value).all
      end
    end

    if records.size > 1 || (records.size == 1 && records[0].hash_key != document.hash_key)
      document.errors.add(attribute, :taken, options.except(:case_sensitive, :scope).merge(value: value))
    end
  end
end
