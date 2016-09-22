# An single controller action, tracked by Ahoy.
# Each individual user visit will likely consist of many events.
class Event
  include Dynamoid::Document

  # associations
  belongs_to :visit
  belongs_to :user

  # fields
  field :name
  field :properties
  field :time, :datetime
end
