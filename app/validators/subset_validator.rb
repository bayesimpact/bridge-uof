# Validates that a record is a subset of a given list.
class SubsetValidator < ActiveModel::EachValidator
  include ActiveModel::Validations::Clusivity

  def validate_each(record, attribute, values)
    return if values.nil?

    values.uniq.each do |value|
      unless include?(record, value)
        record.errors.add(attribute, :inclusion, options.except(:in, :within).merge!(value: value))
      end
    end

    record.errors.add(attribute, :duplicate) unless values.uniq.length == values.length
  end
end
