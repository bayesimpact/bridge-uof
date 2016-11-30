class AdditionalSubmissionInformationsController < ApplicationController

  def new
    @info = AdditionalSubmissionInformation.new(ori: find_ori)
  end

  def create
    @info = AdditionalSubmissionInformation.new(info_params)
    @info.ori = find_ori

    if @info.save
      redirect_user
    else
      render :new
    end
  end

  private
  def info_params
    params.require(:additional_submission_information)
          .permit(:submission_year,
                  :k_9_officer_severirly_injured_count,
                  :non_sworn_uniformed_injured_or_killed_count,
                  :civilians_injured_or_killed_by_non_sworn_uniformed_count)
  end

  def find_ori
    if @current_user.allowed_oris.include?(params[:ori])
      @ori = params[:ori]
    else
      @ori = @current_user.ori
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
