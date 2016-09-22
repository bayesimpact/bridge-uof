# Returns previously-submitted incidents, organized by year.
class PastSubmissionsQuery < Query
  private

    def perform_query(params)
      # raise ActionController::BadRequest.new unless params[:user].admin?

      submitted_incidents = GetAllIncidentsQuery.new.run(user: params[:user]).select(&:submitted?)

      agency_status = AgencyStatus.find_by_ori(params[:user].ori)
      submitted_years = agency_status ? agency_status.complete_submission_years : []

      Hash[submitted_years.map do |year|
        [year, submitted_incidents.select { |i| i.year == year }]
      end]
    end
end
