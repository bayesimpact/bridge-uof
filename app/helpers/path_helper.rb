# Helpers related to paths.
# Also included in ApplicationController.
module PathHelper
  def edit_person_path(type, incident, num)
    send("edit_incident_involved_#{type}_path", incident, num)
  end

  def new_person_path(type, incident)
    send("new_incident_involved_#{type}_path", incident)
  end

  def analytics_path(year)
    dashboard_path(status: 'analytics', year: year)
  end

  def incident_base_url(incident_url)
    parts = incident_url.split("/")
    "/#{parts[1]}/#{parts[2]}"
  end
end
