# An Ursus user.
class User
  include Dynamoid::Document
  include Constants::User

  has_many :incidents
  has_many :feedbacks
  has_many :visits
  has_many :events

  field :first_name
  field :last_name
  field :email
  field :ori
  field :department
  field :role
  field :user_id
  field :splash_complete, :boolean, default: false

  validates :first_name, :last_name, :email, :ori, :department, :role, presence: true
  validates :user_id, presence: true, uniqueness: true

  if Rails.configuration.x.login.use_devise?
    include ValidatesUniqueness # This is necessary when we're using devise, though I'm not quite sure why. -AN

    ############################################################
    #### DEVISE AUTHENTICATION FIELDS
    ############################################################
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable

    validates :password, length: { within: 8..64, allow_blank: true }, confirmation: true

    ## Database authenticatable
    field :encrypted_password, :string, options: { default: "" }

    ## Recoverable
    field :reset_password_token
    field :reset_password_sent_at, :datetime

    ## Rememberable
    field :remember_created_at, :datetime

    ## Trackable
    field :sign_in_count,      :integer, options: { default: 0 }
    field :current_sign_in_at, :datetime
    field :last_sign_in_at,    :datetime
    field :current_sign_in_ip
    field :last_sign_in_ip
  else
    # This is the correct primary key to use, but somehow
    # Devise + Dynamoid together fail at this. No idea why. -EW
    table key: :user_id
  end

  def full_name
    if first_name.present? && last_name.present?
      first_name + " " + last_name
    else
      email
    end
  end

  def admin?
    [Rails.configuration.x.roles.admin, Rails.configuration.x.roles.doj].include? role.downcase
  end

  def doj?
    role.downcase == Rails.configuration.x.roles.doj
  end

  def contracting_oris
    Constants::CONTRACTING_ORIS[ori] || []
  end

  def allowed_oris
    [ori] + contracting_oris
  end

  def agency_last_submission_year
    @agency_last_submission_year ||= AgencyStatus.get_agency_last_submission_year(ori)
  end

  def ==(other)
    return true if other.equal?(self)
    return false unless other.instance_of? self.class
    USER_FIELDS.all? { |f| send(f) == other.send(f) }
  end
end
