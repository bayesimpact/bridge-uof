# An entry in the audit log.
class AuditEntry
  include Dynamoid::Document

  has_one :user
  has_many :changed_fields
  field :custom_text, :string
  field :page, :string
  field :is_new, :boolean
end

# A field that has been changed within an AuditEntry.
class ChangedField
  include Dynamoid::Document

  belongs_to :audit_entry
  field :key, :string
  field :old_value, :string
  field :new_value, :string
end
