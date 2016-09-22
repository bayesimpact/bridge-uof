# All authentication-related controller code goes here, per separation of concerns.
module Authenticates
  include ActiveSupport::Concern

  def self.included(base)
    base.before_action :devise_configure_permitted_parameters, if: :devise_controller?
    base.before_action :authenticate!
  end

  def authenticate!
    if Rails.configuration.x.login.use_devise?
      authenticate_with_devise!
    elsif Rails.configuration.x.login.use_siteminder?
      authenticate_with_siteminder!
    elsif Rails.configuration.x.login.use_demo?
      authenticate_with_demo!
    else
      logger.error("login mechanism is '#{ENV['LOGIN_MECHANISM']}'")
      raise BridgeExceptions::InvalidLoginMechanismError.new
    end
  end

  # This is used by Devise to know where to send the user after they log out.
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  # Devise-specific parameter sanitization code
  def devise_configure_permitted_parameters
    profile_params = User::USER_FIELDS + [:password, :password_confirmation, :current_password]
    [:sign_up, :account_update].each do |method|
      devise_parameter_sanitizer.for(method) { |u| u.permit(*profile_params) }
    end
  end

  # Deletes all cookies associated with demo authentication,
  # and performs related cleanup.
  def reset_demo!
    @current_user.incidents.each(&:destroy) if @current_user

    cookies.delete(:user_id)
    cookies.delete(:hide_demo_msg)
    flash[:notice] = 'You have created a new user account.'
    redirect_to dashboard_path
  end

  private

    def authenticate_with_devise!
      authenticate_user!
      @current_user = current_user
    end

    def authenticate_with_siteminder!
      @current_user = SiteminderAuthenticationService.authenticate!(cookies)
    rescue BridgeExceptions::SiteminderCookieNotFoundError => ex
      display_and_log_siteminder_errors(ex)

      logout_url = Rails.configuration.x.login.siteminder_url_logout
      if logout_url.present?
        redirect_to logout_url
      else
        # logout_url can be blank only in a development or test environment.
        render 'siteminder_auth_fail', status: :unauthorized, layout: false
      end
    rescue BridgeExceptions::SiteminderAuthenticationError => ex
      display_and_log_siteminder_errors(ex)
      render 'siteminder_auth_fail', status: :unauthorized, layout: false
    end

    def authenticate_with_demo!
      @current_user = cookies[:user_id].try { |id| User.find(id) }
      generate_demo_user! unless @current_user
    end

    def display_and_log_siteminder_errors(ex)
      @siteminder_errors = ex.message.split("\n")

      @siteminder_errors.each do |err|
        logger.error("Siteminder authentication error: #{err}")
      end

      # Feedback page won't work without authentication, so present
      # a mailto: url to the user.
      address = Rails.application.config.x.mail.feedback_to_address
      params = { subject: "Siteminder Login Issue", body: "Errors:\n#{@siteminder_errors.join("\n")}" }
      @mailto_url = "mailto:#{address}?#{params.to_param}"
      @concise_address = address =~ /<.*>/ ? address.match(/<(.*)>/)[1] : address
    end

    def generate_demo_user!
      user_id = SecureRandom.uuid

      ori = random_ori
      ori = random_ori until User.where(ori: ori).count.zero?

      cookies[:user_id] = { value: user_id, expires: 1.month.from_now }

      @current_user = User.create!(
        first_name: "Test",
        last_name: "User",
        email: user_id,
        ori: ori,
        department: "Test Dept",
        role: Rails.configuration.x.roles.admin,
        user_id: user_id
      )
    end

    def random_ori
      "CA0#{rand(58).to_s.rjust(2, '0')}#{rand(9999)}"
    end
end
