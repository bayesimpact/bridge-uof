require 'rails_helper'

describe '[AgencyStatus]', type: :model do
  before :each do
    @ori = "ORI_1"
    @status = AgencyStatus.create!(ori: @ori)
    @other_ori = "ORI_2"
    @other_status = AgencyStatus.create!(ori: @other_ori)
  end

  it 'can look up an AgencyStatus by ori with #find_by_ori' do
    expect(AgencyStatus.find_by_ori(@ori)).to eq(@status)
    expect(AgencyStatus.find_by_ori(@other_ori)).to eq(@other_status)
  end

  it 'can indicate agency submission and retrieve information about past submissions' do
    expect(@status.complete_submission_years).to eq []

    @status.mark_year_submitted!(2016)
    expect(@status.complete_submission_years).to eq [2016]
    expect(@status.last_submission_year).to eq 2016

    @status.mark_year_submitted!(2012)
    expect(@status.complete_submission_years).to eq [2012, 2016]
    expect(@status.last_submission_year).to eq 2016

    @status.mark_year_submitted!(2014)
    expect(@status.complete_submission_years).to eq [2012, 2014, 2016]
    expect(@status.last_submission_year).to eq 2016

    # Other agency should be unaffected
    expect(@other_status.complete_submission_years).to eq []
    expect(@other_status.last_submission_year).to eq(-1)
  end

  it 'correctly calculates the agency\'s last submission year' do
    expect(AgencyStatus.get_agency_last_submission_year(@ori)).to eq(-1)
    @status.mark_year_submitted!(2014)
    expect(AgencyStatus.get_agency_last_submission_year(@ori)).to eq 2014
    @status.mark_year_submitted!(2012)
    expect(AgencyStatus.get_agency_last_submission_year(@ori)).to eq 2014
    @status.mark_year_submitted!(2016)
    expect(AgencyStatus.get_agency_last_submission_year(@ori)).to eq 2016
  end
end
