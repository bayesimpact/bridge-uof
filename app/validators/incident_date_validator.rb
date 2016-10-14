# Validates that a date is in the appropriate format and in the past.
class IncidentDateValidator < ActiveModel::EachValidator
  DATE_REGEX = %r{((0[1-9])|(1[0-2]))\/((0[1-9])|([12][0-9])|(3[01]))\/(\d{4})}i

  def validate_each(record, attribute, value)
    valid_years = GlobalState.valid_new_incident_years
    valid_years_str = valid_years.to_a.join(' or ')

    begin
      raise ArgumentError unless value =~ DATE_REGEX
      date = Date.strptime(value, '%m/%d/%Y')

      if valid_years.exclude? date.year
        record.errors[attribute] << "invalid year #{date.year} - you can only create incidents for #{valid_years_str}"
      elsif date > Time.zone.today
        record.errors[attribute] << "future date #{value} not allowed (today is #{Time.zone.today.strftime('%m/%d/%Y')})"
      else
        validate_year_not_submitted_yet(record, attribute, date.year)
      end
    rescue ArgumentError
      record.errors[attribute] << "must be a valid date in MM/DD/YYYY format (you gave #{value})"
    end
  end

  private

    # Ensure that the incident is not being created for a year that has already
    # been submitted for by the given ORI.
    def validate_year_not_submitted_yet(record, attribute, year)
      incident = record.incident.target

      # Only perform this check if the GeneralInfo model has an associated incident
      # (this may not be the case, i.e. when the incident is being created via bulk upload).
      if incident.present?
        ori = record.contracting_for_ori || incident.ori
        submitted_years = AgencyStatus.find_or_create_by_ori(ori).complete_submission_years

        if submitted_years.include? year
          record.errors[attribute] << "ORI #{ori} has already submitted for this year"
        end
      end
    end
end
