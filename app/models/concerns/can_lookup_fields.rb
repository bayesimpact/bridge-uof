# Provides helper methods for determining which fields of a Document are important.
module CanLookupFields
  extend ActiveSupport::Concern

  UNIMPORTANT_FIELDS = [:id, :created_at, :updated_at, :partial].freeze
  UNIMPORTANT_FIELD_SUFFIXES = %w(_id _ids).freeze

  # [Class methods.]
  module ClassMethods
    def important_fields
      # They are the only parameters permitted in a create/update action for a given model
      # (but see #permitted_fields for how we must format them before passing to params.permit()).
      # These are also the fields that are used for serializing / checking equality of incidents.
      @important_fields ||= attributes.keys.select { |f| important_field? f }
    end

    def array_fields
      # These are the fields of a model that have {type: :array}.
      @array_fields ||= attributes.select { |_, v| v[:type] == :array }.keys
    end

    def permitted_fields
      # If important_fields are [:field1, :field2, :array_field]
      # and array_fields are [:array_field],
      # then permitted_fields are [:field1, :field2, {array_field: []}].
      # This is the format that's needed to match a combination of
      # scalar and array fields when doing params.permit() in a controller.
      @permitted_fields ||= important_fields.map do |field|
        if array_fields.include? field
          { field => [] }
        else
          field
        end
      end
    end

    private

      def important_field?(field)
        UNIMPORTANT_FIELDS.exclude?(field) && UNIMPORTANT_FIELD_SUFFIXES.none? { |suff| field.to_s.end_with? suff }
      end
  end
end
