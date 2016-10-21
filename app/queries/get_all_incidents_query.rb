# Returns all incidents potentially visible to a user.
# This is a "sub-query" returning a raw incident set that is
# then used by user-facing queries such as DashboardIncidentsQuery.
class GetAllIncidentsQuery < Query
  private

    def perform_query(params)
      if params[:user].admin?
        # Admins oversee incidents of all users in their ORI and contracting ORIs.
        params[:user].allowed_oris.flat_map do |ori|
          User.where(ori: ori).all.flat_map do |user|
            user.incidents.records
          end
        end
      else
        # Other users only oversee their own incidents.
        params[:user].incidents.records
      end
    end
end
