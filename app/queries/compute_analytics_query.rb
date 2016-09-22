# Computes department-level analytics.
class ComputeAnalyticsQuery < Query
  private

    def perform_query(params)
      {
        all_years: all_years(params[:user]),
        num_incidents: num_incidents(params[:user], params[:year]),
        num_injured_civilians: num_injured_persons(params[:user], params[:year], :civilian),
        num_injured_officers: num_injured_persons(params[:user], params[:year], :officer),
        incidents_by_month: incidents_by_month(params[:user], params[:year])
      }
    end

    def all_years(user)
      all_incidents = GetAllIncidentsQuery.new.run(user: user)
      years = all_incidents.map(&:year).compact.to_set

      years.sort + ['all']
    end

    def num_incidents(user, year)
      incidents_for_year(user, year).count
    end

    def num_injured_persons(user, year, type)
      incidents_for_year(user, year)
        .map { |i| i.send("involved_#{type}s").all.count(&:seriously_injured_or_deceased?) }
        .sum
    end

    def incidents_by_month(user, year)
      incidents = incidents_for_year(user, year)
      months = Date::MONTHNAMES.each_with_index.drop(1)  # Date::MONTHNAMES has a nil first element.

      months.map do |month, idx|
        [month, incidents.count { |i| i.month == idx }]
      end
    end

    def incidents_for_year(user, year)
      GetAllIncidentsQuery.new.run(user: user)
                          .select { |i| i.year == year || year.blank? }  # Filter by year if a year is given.
                          .reject(&:draft?)  # Don't count draft incidents in analytics.
    end
end
