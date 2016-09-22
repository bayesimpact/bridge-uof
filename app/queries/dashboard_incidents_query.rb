# Returns incidents to display on the dashboard.
class DashboardIncidentsQuery < Query
  private

    def perform_query(params)
      agency_last_submission_year = AgencyStatus.get_agency_last_submission_year(params[:user].ori)

      GetAllIncidentsQuery.new.run(user: params[:user])
                          .reject(&:deleted?)  # Don't include deleted incidents.
                          .select { |i| i.year.nil? || i.year > agency_last_submission_year }  # Ignore submitted incidents and old drafts.
                          .select { |i| i.authorized_to_view? params[:user] }  # Only show incidents user is authorized to see.
                          .sort_by { |i| i.created_at.to_i }.reverse!  # Display reverse chronologically.
    end
end
