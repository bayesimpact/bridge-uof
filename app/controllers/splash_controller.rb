# Controller for splash pages.
class SplashController < ApplicationController
  skip_before_action :consider_splash

  def splash_show
    render "splash_#{Rails.configuration.x.branding.name}", layout: nil
  end

  def splash_dismiss
    @current_user.update_attributes(splash_complete: true)
    redirect_to dashboard_path
  end
end
