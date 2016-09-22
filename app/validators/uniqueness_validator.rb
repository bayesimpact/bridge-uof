# This is necessary for models that use devise, though I'm not quite sure why. -AN
class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(document, attribute, value)
    chain = Dynamoid::Criteria::Chain.new(document.class)
    chain.where(attribute => value)
    records = chain.all

    if records.size > 1 || (records.size == 1 && records[0].hash_key != document.hash_key)
      document.errors.add(attribute, :taken, options.except(:case_sensitive, :scope).merge(value: value))
    end
  end
end
