# A visit to Ursus, tracked by Ahoy.
# Note that the field names are defined by Ahoy - if they are renamed,
# they will not be set correctly.
class Visit
  include Dynamoid::Document

  # associations
  belongs_to :user

  # required
  field :visitor_id

  # the rest are recommended but optional
  # simply remove the columns you don't want

  # standard
  field :ip
  field :user_agent
  field :referrer
  field :landing_page

  # traffic source
  field :referring_domain
  field :search_keyword

  # technology
  field :browser
  field :os
  field :device_type
  field :screen_height, :integer
  field :screen_width, :integer

  # location
  field :country
  field :region
  field :city

  # utm parameters
  # field :utm_source
  # field :utm_medium
  # field :utm_term
  # field :utm_content
  # field :utm_campaign

  field :started_at, :datetime
end
