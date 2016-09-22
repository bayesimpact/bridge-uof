# A piece of user feedback.
class Feedback
  include Dynamoid::Document
  include CanLookupFields

  belongs_to :user

  field :source, :string
  field :content, :string

  validates :content, presence: true
end
