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

    # Hash representation of input JSON format.
    def json_schema
      attributes.slice(*important_fields)
                .map { |field, metadata| [field, "<#{displayed_type(field, metadata[:type])}>"] }
                .to_h
    end

    # String representation of input XML format.
    def xml_schema
      attributes.slice(*important_fields)
                .map { |field, metadata| format_xml_field_for_schema(field, metadata) }
                .join
    end

    private

      def displayed_type(field, type)
        # Get a string of options for this field, if Incident::OPTIONS_PER_FIELD[field] is defined.
        options = Incident::OPTIONS_PER_FIELD[field].try do |opts|
          opts.map { |o| "'#{o}'" }.join(', ').sub("&", "&amp;")
        end

        case type
        when :string
          if options.present?
            field.to_s.include?('order') ? "(optional) any of [#{options}], separated by ' -> '" : "one of [#{options}]"
          else
            'string'
          end
        when :boolean
          "'t' or 'f'"
        when :array
          "array of [#{options}]"
        else
          type
        end
      end

      def format_xml_field_for_schema(field, metadata)
        tag_name = field.to_s.tr('_', '-')
        if metadata[:type] == :array
          %(
            <#{tag_name} type="array">
              <#{tag_name}>
                {{ #{displayed_type(field, :string)} }}
              </#{tag_name}>
            </#{tag_name}>
          )
        else
          %(
            <#{tag_name}>
              {{ #{displayed_type(field, metadata[:type])} }}
            </#{tag_name}>
          )
        end
      end
  end
end
