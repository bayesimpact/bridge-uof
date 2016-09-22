# Provides to_hash and from_hash methods for Documents,
# as well as a custom equal? method, such that:
#   Doc.from_hash(doc.to_hash).equal? doc
# Imports the CanLookupFields concern, which is needed to provide
# a set of serializable fields.
module Serializable
  extend ActiveSupport::Concern
  include CanLookupFields

  def equal?(other)
    important_fields = self.class.important_fields
    attributes.slice(*important_fields) == other.attributes.slice(*important_fields)
  end

  def to_hash
    dump.slice(*self.class.important_fields)
  end

  # [Class methods.]
  module ClassMethods
    def from_hash(hash)
      hash.keys.each do |field|
        if attributes.keys.exclude? field.to_sym
          raise BridgeExceptions::DeserializationError.new("unexpected field: #{field} in #{name}")
        end
      end

      create(hash)
    end

    def schema
      # Hash representation of input JSON format
      attributes.slice(*important_fields)
                .map { |field, metadata| [field, "<#{displayed_type(field, metadata)}>"] }
                .to_h
    end

    private

      def displayed_type(field, metadata)
        # Get a string of options for this field, if Incident::OPTIONS_PER_FIELD[field] is defined.
        options = Incident::OPTIONS_PER_FIELD[field].try { |opts| opts.map { |o| "'#{o}'" }.join(', ') }

        case metadata[:type]
        when :string
          if options.present?
            field.to_s.include?('order') ? "(optional) any of [#{options}], separated by ' -> '" : "one of [#{options}]"
          else
            'string'
          end
        when :boolean
          "'y' or 'n'"
        when :array
          "array of [#{options}]"
        else
          metadata[:type]
        end
      end
  end
end
