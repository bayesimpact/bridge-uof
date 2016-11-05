require 'json'
require 'rexml/document'

# An incident filed within Ursus.
class Incident
  include Dynamoid::Document
  include IncidentAuthorization
  include Constants::Incident

  before_destroy :destroy_associated!

  has_one :screener
  has_one :general_info
  has_many :involved_officers
  has_many :involved_civilians
  has_many :audit_entries
  belongs_to :user

  field :status, :string, default: STATUS_TYPES.first
  # The IncidentId value object is accessed through the #incident_id method.
  field :incident_id_str, :string

  global_secondary_index hash_key: :incident_id_str, projected_attributes: [hash_key]

  validates :user, :ori, presence: true
  validates :incident_id_str, uniqueness: true, allow_nil: true

  delegate :on_k12_campus, to: :general_info, allow_nil: true

  # For convenience, we programmatically create a set of getters draft?, in_review?, etc.
  # and a set of setters draft!, in_review!, etc. to check or set the status of an incident.
  STATUS_TYPES.each do |value|
    class_eval "def #{value}?() self.status == '#{value}' end"
    class_eval "def #{value}!() update_attributes status: '#{value}' end"
  end

  def ori
    general_info.target.try(:ori) || user.target.try(:ori)
  end

  # This is the accessor method for the IncidentId value object.
  def incident_id
    @incident_id || IncidentId.new(self)
  end

  def next_step
    if submitted?
      # Don't run validation for submitted incidents because
      # we already know they're completely valid.
      :review
    elsif screener.nil? || screener.invalid?
      :screener
    elsif general_info.nil? || general_info.invalid?
      :general_info
    elsif involved_civilians.to_a.count(&:valid?) < general_info.num_involved_civilians
      :involved_civilians
    elsif involved_officers.to_a.count(&:valid?) < general_info.num_involved_officers
      :involved_officers
    else
      :review
    end
  end

  def next_step_number
    STEP_URLS.index(next_step)
  end

  def step_accessible?(step)
    STEP_URLS.index(step) <= next_step_number
  end

  def complete?
    next_step == :review
  end

  def status_as_string
    if draft?
      if complete?
        "Complete, not yet sent for review"
      else
        "In progress"
      end
    else
      status.to_s.tr('_', ' ').capitalize
    end
  end

  def year
    general_info.target.try(:compute_datetime).try(:year)
  end

  def month
    general_info.target.try(:compute_datetime).try(:month)
  end

  def department
    # In production, ori will always be valid, so Constants::DEPARTMENT_BY_ORI[ori] will exist.
    # But in an environment with DEMO or DEVISE authentication, ori might not be valid,
    # so just fall back to user.department (which should always exist).
    Constants::DEPARTMENT_BY_ORI[ori] || user.department
  end

  def stats(opts = {})
    IncidentStatsService.get_stats_for_incident(self, opts)
  end

  # Custom equality method for Incidents.
  # Returns true iff all fields in this Incident's screener, general_info, and involved persons
  # match the corresponding fields in `other` (delegates to Serializable#equal?).
  def equal?(other)
    raise "Incident is not complete" unless complete? && other.complete?

    screener.target.equal?(other.screener) &&
      general_info.target.equal?(other.general_info) &&
      involved_civilians.zip(other.involved_civilians).all? { |c1, c2| c1.equal? c2 } &&
      involved_officers.zip(other.involved_officers).all? { |o1, o2| o1.equal? o2 }
  end

  def self.from_hash(json, user)
    IncidentDeserializerService.from_hash(json, user)
  end

  def to_hash
    raise "Incident is not complete" unless complete?

    {
      ori: ori,
      screener: screener.to_hash,
      general_info: general_info.to_hash,
      involved_civilians: involved_civilians.map(&:to_hash),
      involved_officers: involved_officers.map(&:to_hash)
    }
  end

  def self.json_schema
    raw_json_schema = {
      'ori' => '<string>',
      'screener' => Screener.json_schema,
      'general_info' => GeneralInfo.json_schema,
      'involved_civilians[]' => InvolvedCivilian.json_schema,
      'involved_officers[]' => InvolvedOfficer.json_schema
    }

    # Apply some formatting to the schema for display purposes.
    JSON.pretty_generate(raw_json_schema)
        .gsub(/"(<.*>)"/, "\\1")   # remove quotes from <type>s
        .tr("'", '"')
  end

  def self.xml_schema
    raw_xml_schema = %(
      <?xml version="1.0" encoding="UTF-8"?>
      <incidents type="array">
        <incident>
          <ori>{{ string }}</ori>
          <screener>
            #{Screener.xml_schema}
          </screener>
          <general-info>
            #{GeneralInfo.xml_schema}
          </general-info>
          <involved-civilians type="array">
            <involved-civilian>
              #{InvolvedCivilian.xml_schema}
            </involved-civilian>
          </involved-civilians>
          <involved-officers type="array">
            <involved-officer>
              #{InvolvedOfficer.xml_schema}
            </involved-officer>
          </involved-officers>
        </incident>
      </incidents>
    )

    formatted_xml = ""
    REXML::Document.new(raw_xml_schema).write(output: formatted_xml, indent: 2)
    formatted_xml
  end

  protected

    def destroy_associated!
      screener.target.destroy unless screener.nil?
      general_info.target.destroy unless general_info.nil?
      involved_officers.each(&:destroy)
      involved_civilians.each(&:destroy)
    end
end
