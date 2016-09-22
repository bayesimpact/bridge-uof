# Controller for DOJ dashboard.
class DojController < ApplicationController
  before_action :block_non_doj_users

  def overview
  end

  def window
  end

  def window_toggle
    if params[:submission_year] == Time.last_year.to_s && params[:submission_open] == GlobalState.submission_open?.to_s
      GlobalState.toggle_submission_window!
    else
      logger.error "Invalid submission window toggle - hidden form fields do not match up with current submission state"
      logger.error "Expected (#{Time.last_year}, #{GlobalState.submission_open?}) - " \
                   "got (#{params[:submission_year]}, #{params[:submission_open]})"
    end
    redirect_to doj_window_path
  end

  def whosubmitted
    @agency_statuses = AgencyStatus.all
    @agencies = Constants::DEPARTMENT_BY_ORI.map { |ori, dept| get_agency_status_hash(ori, dept) }
                                            .sort_by { |a| a[:ori] }
  end

  def incidents
    return unless params[:ori].present?

    @ori = params[:ori].strip.split[-1]

    if Constants::DEPARTMENT_BY_ORI.include? @ori
      @dept = Constants::DEPARTMENT_BY_ORI[@ori].split.map(&:capitalize).join(' ')
      all_oris = [@ori] + Constants::CONTRACTING_ORIS[@ori].to_a
      @incidents = Incident.all.select { |i| i.submitted? && all_oris.include?(i.ori) }
      @agency_last_submission_year = AgencyStatus.get_agency_last_submission_year(@ori)
    else
      @bad_ori = true
    end
  end

  def analysis
  end

  private

    def block_non_doj_users
      raise ActionController::BadRequest.new unless @current_user.doj?
    end

    def get_agency_status_hash(ori, dept)
      status = @agency_statuses.find { |s| s.ori == ori }
      {
        ori: ori,
        department: dept,
        submitted: status && status.last_submission_year && status.last_submission_year >= Time.last_year
      }
    end
end
