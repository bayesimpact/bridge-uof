# Helper methods pertaining to displaying components of incidents.
module IncidentHelper
  def display_ori(ori)
    "#{Constants::DEPARTMENT_BY_ORI[ori]} (#{ori})"
  end

  def render_incident_id(incident)
    render partial: "incident_id", locals: { value: incident.incident_id }
  end

  def audit_entry_description(entry)
    name = entry.user.full_name
    date = entry.created_at.strftime("%a %b %-d %Y at %H%M")

    if entry.custom_text
      "#{name} #{entry.custom_text} on #{date}."
    elsif entry.is_new
      "#{name} filled out the #{entry.page} page on #{date}."
    else
      "#{name} edited the #{entry.page} page on #{date} and updated the following fields:"
    end
  end

  def show_changed_fields_for_audit_entry?(entry)
    !entry.custom_text && !entry.is_new
  end
end
