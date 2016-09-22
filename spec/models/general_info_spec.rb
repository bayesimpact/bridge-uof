require 'rails_helper'

describe '[General Info]', type: :model do
  describe '[Validation]' do
    before :each do
      @info = create :general_info
    end

    it 'validates a model with all correct fields' do
      expect(@info.valid?).to be true
    end

    it 'requries a (valid) in_custody_reason if contact_reason is "in custody"' do
      @info.contact_reason = GeneralInfo::CONTACT_REASON_IN_CUSTODY
      expect(@info.valid?).to be false
      @info.in_custody_reason = 'foobarbaz'
      expect(@info.valid?).to be false
      @info.in_custody_reason = GeneralInfo::IN_CUSTODY_REASONS[0]
      expect(@info.valid?).to be true
    end

    it 'requires at least 1 and at most 20 officers and civilians involved' do
      @info.num_involved_civilians = 1
      @info.num_involved_officers = 1
      expect(@info.valid?).to be true

      @info.num_involved_civilians = 0
      expect(@info.valid?).to be false
      @info.num_involved_civilians = 21
      expect(@info.valid?).to be false
      @info.num_involved_civilians = 20
      expect(@info.valid?).to be true

      @info.num_involved_officers = 0
      expect(@info.valid?).to be false
      @info.num_involved_officers = 21
      expect(@info.valid?).to be false
      @info.num_involved_officers = 20
      expect(@info.valid?).to be true
    end

    describe "[address]" do
      INVALID_STATES = %w(C AA 01).freeze  # can't test "California" because the input has maxlength=2
      INVALID_ZIP_CODES = %w(abcde 911).freeze  # can't test "123456" because the input has maxlength=5

      it 'rejects invalid states' do
        INVALID_STATES.each do |invalid_state|
          @info.state = invalid_state
          expect(@info.valid?).to be false
        end
      end

      it 'accepts valid states, whether upper or lower case' do
        @info.state = 'ca'
        expect(@info.valid?).to be true
        @info.state = 'CA'
        expect(@info.valid?).to be true
        @info.state = 'cA'
        expect(@info.valid?).to be true
        @info.state = 'FL'  # For now, all states are valid
        expect(@info.valid?).to be true
      end

      it 'rejects invalid zip codes' do
        INVALID_ZIP_CODES.each do |invalid_zip_code|
          @info.zip_code = invalid_zip_code
          expect(@info.valid?).to be false
        end
      end

      it 'accepts valid zip codes' do
        @info.zip_code = '00000'
        expect(@info.valid?).to be true
        @info.zip_code = '94103'
        expect(@info.valid?).to be true
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
          @info.incident_date_str = date_str
          expect(@info.valid?).to be true
          expect(@info.compute_datetime).to eq(expected_date)
        end
      end

      it 'rejects invalid, future, or mis-formatted dates' do
        INVALID_DATES.each do |invalid_date|
          @info.incident_date_str = invalid_date
          expect(@info.valid?).to be false
        end
      end

      it 'rejects invalid or mis-formatted times' do
        INVALID_TIMES.each do |invalid_time|
          @info.incident_time_str = invalid_time
          expect(@info.valid?).to be false
        end
      end
    end
  end
end
