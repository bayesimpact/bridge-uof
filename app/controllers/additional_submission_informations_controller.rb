# Voluntary submission information controller for creation only.
class AdditionalSubmissionInformationsController < ApplicationController
  def new
    @info = AdditionalSubmissionInformation.new(ori: find_ori)
  end

  def create
    info_params = get_formatted_params(params, AdditionalSubmissionInformation)
    @info = AdditionalSubmissionInformation.new(info_params)
    @info.ori = find_ori

    if @info.save
      redirect_user
    else
      render :new
    end
  end

  private

    def find_ori
      if @current_user.allowed_oris.include?(params[:ori])
        params[:ori]
      else
        @current_user.ori
      end
    end

    def redirect_user
      if @current_user.allowed_oris.reject { |ori| current_year_voluntary_info?(ori) }.any?
        redirect_to [:new, :additional_submission_information]
      else
        redirect_to dashboard_url(status: 'past_submissions')
      end
    end

    def current_year_voluntary_info?(ori)
      AdditionalSubmissionInformation.where(submission_year: Time.last_year.to_s)
                                     .any? { |asi| asi.ori == ori }
    end
end
