# Gives Documents the ability to be saved without validation.
#
# Note that partial=true renders a document invalid, so if a
# document has previously been partially saved, you must give
# it partial=false before you can save it without validation.
module AllowsPartialSave
  extend ActiveSupport::Concern

  included do
    field :partial, :boolean
    validates :partial, acceptance: { accept: false }
  end

  def partial_save(attributes)
    attributes.each { |attribute, value| self[attribute] = value }
    self["partial"] = true
    save(validate: false)
  end
end
