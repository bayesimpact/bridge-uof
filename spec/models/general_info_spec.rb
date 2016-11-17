require 'rails_helper'

describe GeneralInfo, type: :model do
  describe '[Validation]' do
    let(:incident) { create(:incident) }
    let(:gi) { incident.general_info }

    it 'validates a model with all correct fields' do
      expect(gi.valid?).to be true
    end

    it 'requries a (valid) in_custody_reason if contact_reason is "in custody"' do
      gi.contact_reason = GeneralInfo::CONTACT_REASON_IN_CUSTODY
      expect(gi.valid?).to be false
      gi.in_custody_reason = 'foobarbaz'
      expect(gi.valid?).to be false
      gi.in_custody_reason = GeneralInfo::IN_CUSTODY_REASONS[0]
      expect(gi.valid?).to be true
    end

    it 'requires at least 1 and at most 20 officers and civilians involved' do
      gi.num_involved_civilians = 1
      gi.num_involved_officers = 1
      expect(gi.valid?).to be true

      gi.num_involved_civilians = 0
      expect(gi.valid?).to be false
      gi.num_involved_civilians = 21
      expect(gi.valid?).to be false
      gi.num_involved_civilians = 20
      expect(gi.valid?).to be true

      gi.num_involved_officers = 0
      expect(gi.valid?).to be false
      gi.num_involved_officers = 21
      expect(gi.valid?).to be false
      gi.num_involved_officers = 20
      expect(gi.valid?).to be true
    end

    it 'does not raise uniqueness validation if incident status is deleted' do
      incident.update_attribute(:status, 'deleted')
      duplicate = build(:general_info, ori: gi.ori, city: gi.city,
                                       address: gi.address,
                                       incident_date_str: gi.incident_date_str,
                                       incident_time_str: gi.incident_time_str)
      expect { duplicate.save! }.not_to raise_error
    end

    it 'raises uniqueness validation of general info based on ori, city, address, date, and time if incident without deleted incident' do
      duplicate = build(:general_info, ori: gi.ori, city: gi.city,
                                       address: gi.address,
                                       incident_date_str: gi.incident_date_str,
                                       incident_time_str: gi.incident_time_str)
      expect { duplicate.save! }.to raise_error(/there is already another incident with this same date, time, address, city, and ORI - are you sure you didn't fill out this incident report already?/)
    end

    it 'raise uniqueness validation if incident deleted' do
      incident.delete
      duplicate = build(:general_info, ori: gi.ori, city: gi.city,
                                       address: gi.address,
                                       incident_date_str: gi.incident_date_str,
                                       incident_time_str: gi.incident_time_str)
      expect { duplicate.save! }.to raise_error(/there is already another incident with this same date, time, address, city, and ORI - are you sure you didn't fill out this incident report already?/)
    end

    describe "[address]" do
      INVALID_STATES = %w(C AA 01).freeze  # can't test "California" because the input has maxlength=2
      INVALID_ZIP_CODES = %w(abcde 911).freeze  # can't test "123456" because the input has maxlength=5

      it 'rejects invalid states' do
        INVALID_STATES.each do |invalid_state|
          gi.state = invalid_state
          expect(gi.valid?).to be false
        end
      end

      it 'accepts valid states, whether upper or lower case' do
        gi.state = 'ca'
        expect(gi.valid?).to be true
        gi.state = 'CA'
        expect(gi.valid?).to be true
        gi.state = 'cA'
        expect(gi.valid?).to be true
        gi.state = 'FL'  # For now, all states are valid
        expect(gi.valid?).to be true
      end

      it 'rejects invalid zip codes' do
        INVALID_ZIP_CODES.each do |invalid_zip_code|
          gi.zip_code = invalid_zip_code
          expect(gi.valid?).to be false
        end
      end

      it 'accepts valid zip codes' do
        gi.zip_code = '00000'
        expect(gi.valid?).to be true
        gi.zip_code = '94103'
        expect(gi.valid?).to be true
      end
    end

    describe "[date and time]" do
      # Reminder: date and time are mocked in config/environments/test.rb
      # and set to 2040-12-31 16:30
      VALID_DATES = {
        "12/31/2039" => Time.zone.local(2039, 12, 31, 14, 0),
        "01/01/2040" => Time.zone.local(2040, 1, 1, 14, 0),
        # "02/29/2040" => DateTime.new(2040, 2, 29, 16, 30)  # Timecop has a bug that makes it handle 2/29 very poorly. This works in prod, though.
      }.freeze

      INVALID_DATES = [
        "02282040",   # improperly formatted
        "02-28-2040", # improperly formatted
        # "02/29/2039", # invalid date, not a leap year  # Timecop has a bug that makes it handle 2/29 very poorly.
        "20/20/2040", # invalid date
        "01/01/2038", # invalid year, before current submission window
        "01/01/9999"  # invalid year / in the future
      ].freeze

      INVALID_TIMES = ["16:30", "2500", "1299", "430", "11111"].freeze

      before :all do
        GlobalState.open_submission_window!
      end

      it 'accepts valid dates and times and computes the full datetime string' do
        VALID_DATES.each do |date_str, expected_date|
          gi.incident_date_str = date_str
          expect(gi.valid?).to be true
          expect(gi.compute_datetime).to eq(expected_date)
        end
      end

      it 'rejects invalid, future, or mis-formatted dates' do
        INVALID_DATES.each do |invalid_date|
          gi.incident_date_str = invalid_date
          expect(gi.valid?).to be false
        end
      end

      it 'rejects invalid or mis-formatted times' do
        INVALID_TIMES.each do |invalid_time|
          gi.incident_time_str = invalid_time
          expect(gi.valid?).to be false
        end
      end
    end
  end
end
