# Adds validates_uniqueness_of() to models (see validators/uniqueness_validator.rb).
module ValidatesUniqueness
  extend ActiveSupport::Concern

  # [Class methods.]
  module ClassMethods
    def validates_uniqueness_of(*atts)
      validates_with(UniquenessValidator, _merge_attributes(atts))
    end
  end
end
