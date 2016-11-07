require 'rails_helper'

describe '[DOJ Dashboard]', type: :request do
  it 'prevents non-DOJ users from seeing the DOJ dashboard' do
    login
    expect { visit doj_path }.to raise_error(ActionController::BadRequest)
  end

  describe '[with some mock data]' do
    let!(:elvis) do
      create(:dummy_user, first_name: "Elvis", last_name: "Presley",
                          email: "elvis@example.com", role: Rails.configuration.x.roles.doj,
                          user_id: 'elvis', ori: 'ALPHA_ORI')
    end

    describe '[logged in as a DOJ user]' do
      before :each do
        login user: elvis
      end

      it 'redirects DOJ users from the normal dashboard to the DOJ one' do
        expect(current_path).to eq(doj_path)
        visit dashboard_path
        expect(current_path).to eq(doj_path)
      end

      it '/window allows opening and closing the submission window' do
        # By default, window is closed and submission is expected for the previous year
        expect(GlobalState.submission_not_yet_open?).to be true
        expect(GlobalState.submission_open?).to be false
        expect(GlobalState.submission_closed_for_year?).to be false
        visit doj_window_path
        btn = find("input[type=submit]")
        expect(btn['value']).to eq("Open the window now")

        # Open the window
        btn.click
        expect(GlobalState.submission_not_yet_open?).to be false
        expect(GlobalState.submission_open?).to be true
        expect(GlobalState.submission_closed_for_year?).to be false
        expect(page).to have_content("Submission for #{Time.last_year} is OPEN")
        btn = find("input[type=submit]")
        expect(btn['value']).to eq("Close the window now")

        # Close the window, advance to the next year
        btn.click
        expect(GlobalState.submission_not_yet_open?).to be false
        expect(GlobalState.submission_open?).to be false
        expect(GlobalState.submission_closed_for_year?).to be true
        expect(page).to have_content("Submission for #{Time.last_year} is CLOSED")
        btn = find("input[type=submit]")
        expect(btn['value']).to eq("Re-open the window for #{Time.last_year}")

        # Can still reopen the window for the current year
        btn.click
        expect(GlobalState.submission_not_yet_open?).to be false
        expect(GlobalState.submission_open?).to be true
        expect(GlobalState.submission_closed_for_year?).to be false
        expect(page).to have_content("Submission for #{Time.last_year} is OPEN")
      end
    end

    describe '[with an open submission window and one agency having submitted one incident]' do
      before :each do
        GlobalState.open_submission_window!

        # Log in as a regular admin user, make an incident, submit to state
        user = build(:dummy_user, ori: 'ALPHA_ORI')
        login user: user
        create(:incident)
        review_incident
        submit_to_state
        logout

        # Log back in as DOJ user
        login user: elvis
      end

      it '/whosubmitted shows agency submission statuses and links to their incidents' do
        # Ensure that there are only two incidents.
        stub_const('Constants::DEPARTMENT_BY_ORI', 'ALPHA_ORI' => 'ALPHA_DEPT', 'BRAVO_ORI' => 'BRAVO_DEPT')

        visit doj_whosubmitted_path
        rows = all('#agency-submissions-table tbody tr')
        expect(rows.length).to eq(2)
        expect(rows[0].first('td').text).to eq('ALPHA_ORI')
        expect(rows[0].all('td')[2].text).to eq('YES')
        expect(rows[1].first('td').text).to eq('BRAVO_ORI')
        expect(rows[1].all('td')[2].text).to eq('NO')

        click_link 'View Incidents'
        expect(current_path).to eql('/doj/incidents/ALPHA_ORI')
      end

      it '/incidents allows viewing the incidents of each submitting ORI' do
        visit url_for(controller: 'doj', action: 'incidents', ori: 'ALPHA_ORI')
        expect(page).to have_content('Alpha_dept')  # Should format case
        rows = all('table tbody tr')
        expect(rows.length).to eq(1)

        visit url_for(controller: 'doj', action: 'incidents', ori: 'BRAVO_ORI')
        expect(page).to have_content('Bravo_dept')
        expect(page).to have_no_selector('table')
        expect(page).to have_content("This agency has not yet submitted")

        visit url_for(controller: 'doj', action: 'incidents', ori: 'GAMMA_ORI')
        expect(page).to have_content('GAMMA_ORI is not a valid ORI')
        expect(page).to have_no_selector('table')
      end

      it 'allows searching via the search box' do
        visit url_for(controller: 'doj', action: 'incidents')
        fill_in 'ori', with: 'ALPHA_ORI'
        click_button 'GO'
        expect(page).to have_content('Alpha_dept')

        fill_in 'ori', with: 'All that matters is that this ends with BRAVO_ORI'
        click_button 'GO'
        expect(page).to have_content('Bravo_dept')
      end
    end
  end
end
