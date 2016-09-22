# Returns the number of drafts still being filled out by each employee in the user's ORI.
class EmployeeDraftCountsQuery < Query
  private

    def perform_query(params)
      raise ActionController::BadRequest.new unless params[:user].admin?

      all_incidents = GetAllIncidentsQuery.new.run(user: params[:user])

      all_incidents.each_with_object(Hash.new(0)) do |i, counts|
        counts[i.user.full_name] += 1 if i.draft? && (i.user != params[:user])
      end
    end
end
