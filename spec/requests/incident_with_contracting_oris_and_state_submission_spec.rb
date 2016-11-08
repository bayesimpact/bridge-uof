require 'rails_helper'

describe '[Incident with contracting ORI relationships]', type: :request do
  let(:roles) { Rails.configuration.x.roles }
  let(:parent_ori_user) { build(:dummy_user, email: "1@example.com", ori: 'PARENT_ORI', role: roles.user, user_id: 'parentuser') }
  let(:sub_ori_user) { build(:dummy_user, email: "2@example.com", ori: 'SUB_ORI', role: roles.user, user_id: 'subuser') }
  let(:parent_ori_admin) { build(:dummy_user, email: "3@example.com", ori: 'PARENT_ORI', role: roles.admin, user_id: 'parentadmin') }

  describe '[users of a contracting ORI]' do
    before :each do
      login(user: parent_ori_user)
      create_partial_incident :general

      expect(page).to have_content('Which agency are you filling out this report on behalf of?')
      expect(page).to have_content('Our records indicate that your department provides policing services for 1 contract city')
      expect(page).to have_css('select option', count: 2)

      select "SUB_DEPT (SUB_ORI)"
      answer_all_general_info submit: true
    end

    it 'can create incidents for contracted ORIs, and set ORI and dept accordingly' do
      incident = Incident.first
      expect(incident.ori).to eq("SUB_ORI")
      expect(incident.department).to eq("SUB_DEPT")
    end

    it 'can see all of their incidents regardless of ORI' do
      create_partial_incident :general
      select "PARENT_DEPT (PARENT_ORI)"
      answer_all_general_info submit: true

      visit_status :draft

      expect(page).to have_css('#incidents-table tbody tr', count: 2)
    end
  end

  describe '[users of a non-contracting ORI]' do
    before :each do
      login(user: sub_ori_user)
    end

    it 'can\'t create incidents for other ORIs' do
      create_partial_incident :general

      expect(page).to have_no_content('Which agency are you filling out this report on behalf of?')
      expect(page).to have_no_css('select')
    end

    it 'don\'t see the ORI column on the dashboard' do
      visit_status :draft
      expect(page).to have_no_content('ORI')
    end
  end

  describe '[admins of a contracting ORI]' do
    it 'can see all incidents created by their own or contracted ORIs' do
      login(user: sub_ori_user)
      create(:incident, user_id: sub_ori_user.user_id)
      logout

      login(user: parent_ori_user)
      create(:incident, user_id: parent_ori_user.user_id)
      logout

      login(user: parent_ori_admin)
      visit_status :in_review

      expect(page).to have_css('#incidents-table tbody tr', count: 2)
    end
  end

  describe '[state submission (done as a contracting ORI for completeness)]' do
    let(:current_submission_year) { Time.current.year - 1 }
    let(:previous_submission_year) { current_submission_year - 1 }

    before :each do
      [parent_ori_admin.ori, sub_ori_user.ori].each do |ori|
        AgencyStatus.create!(ori: ori).mark_year_submitted!(previous_submission_year)
      end

      login(user: parent_ori_user)
      create(:incident, user_id: parent_ori_user.user_id)
      logout

      login(user: parent_ori_admin)
      visit_status :in_review
      find('a', text: 'View').click
      expect(current_path).to end_with('/review')
      click_button 'Mark as reviewed'
    end

    it 'before the window is opened, has no submission button and renders the right message' do
      visit_status :state_submission
      expect(page).to have_content("not yet open")
      expect(page).not_to have_button('SUBMISSION')
    end

    it 'allows state submission during the submission window' do
      expect(status_nav_count(:approved)).to eq(1)
      expect(visit_status_count_incidents(:past_submissions)).to eq(0)

      GlobalState.open_submission_window!
      visit_status :state_submission
      expect(page).to have_content("1 incident ready for state submission")
      expect(page).to have_content("You may now submit incidents")
      click_button 'SUBMISSION'

      expect(AgencyStatus.where(ori: parent_ori_admin.ori).first.last_submission_year).to eq(current_submission_year)
      expect(AgencyStatus.where(ori: sub_ori_user.ori).first.last_submission_year).to eq(current_submission_year)
      expect(status_nav_count(:approved)).to eq(0)
      expect(visit_status_count_incidents(:past_submissions)).to eq(1)

      # Submitted incidents are not deletable
      visit_status :past_submissions
      expect(page).to have_css('#incidents-table')
      find('a', text: 'View').click
      expect(page).to have_no_content('Delete')
      # Make sure that even if that button existed, the admin user still wouldn't be authorized to delete it.
      expect(Incident.first).not_to be_authorized_to_edit(parent_ori_admin)

      # Disables subsequent state submission
      visit_status :state_submission
      expect(page).not_to have_button('SUBMISSION')
      expect(page).to have_content("Submission complete")
    end

    it 'state submission fails if any incidents in the ORI are not complete' do
      GlobalState.open_submission_window!

      # Submission fails with draft incident

      create(:incident, user_id: parent_ori_admin.user_id, submit: false)

      visit_status :state_submission
      expect(status_nav_count(:draft)).to eq(1)

      click_button 'SUBMISSION'
      expect(page).to have_content("Your agency has 1 unreviewed incident")

      visit_status :state_submission
      expect(page).not_to have_content("Submission complete")

      # Submission fails with in_review incident

      visit_status :draft
      click_link 'Edit'
      click_button 'Send for review'

      visit_status :state_submission
      expect(status_nav_count(:in_review)).to eq(1)

      click_button 'SUBMISSION'
      expect(page).to have_content("Your agency has 1 unreviewed incident")

      visit_status :state_submission
      expect(page).not_to have_content("Submission complete")
    end

    it 'shows a "Past Submissions" entry for 0-incident-submission years' do
      status = AgencyStatus.find_by_ori(parent_ori_admin.ori)
      status.mark_year_submitted!(1337)  # Add another past submission for good measure
      expect(status.nil?).to be false
      expect(status.complete_submission_years).to eq([1337, previous_submission_year])
      visit_status :past_submissions
      expect(page).to have_content("1337 (0 incidents)")
      expect(page).to have_content("#{previous_submission_year} (0 incidents)")
      expect(page).to have_no_css('#incidents-table')
    end

    it 'after the window has closed for the year, has no submission button and renders the right message' do
      GlobalState.open_submission_window!
      GlobalState.close_submission_window!
      visit_status :state_submission
      expect(page).to have_content("is closed out")
    end
  end
end
