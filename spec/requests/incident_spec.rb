require 'rails_helper'

describe '[Incident]', type: :request do
  def check_for_question(choice, options = {})
    within('div.form-group', text: options[:text]) do
      check choice
    end
  end

  describe '[from a single logged-in (admin) user]' do
    before :each do
      login
      @user = User.first
    end

    it 'smoke test -- create a complete incident, send for review' do
      create_complete_incident
    end

    it 'does not create incidents until the screener page is filled out' do
      new_incident
      visit_status :draft
      expect(Incident.count).to eq(0)
    end

    it 'create a complete incident, exercising all options', driver: :poltergeist do
      new_incident

      expect(current_path).to end_with('/screener')
      expect(page).to have_content('Do I need to file this incident')
      choose_for_question 'No', text: 'multiple agencies'
      choose_for_question 'No', text: 'firearms discharged'
      choose_for_question 'Yes', text: 'officers use force on a civilian'
      choose_for_question 'Yes', text: 'cause serious injury or death to a civilian'
      choose_for_question 'Yes', text: 'civilians assault an officer'
      choose_for_question 'Yes', text: 'serious injury or death to an officer'
      click_button 'Save and Continue'

      expect(current_path).to end_with('/general_info')
      expect(page).to have_content('General Incident Information')
      today = Time.zone.today
      default_date = Date.new(today.year - 1, today.month, today.day)
      fill_in 'Date', with: default_date.strftime('%m/%d/%Y')
      fill_in 'Time', with: '1830'
      fill_in 'Incident Address', with: '1355 Market St'
      fill_in 'City', with: 'San Francisco'
      fill_in 'State', with: 'CA'
      fill_in 'Zip', with: '94103'
      fill_in 'County', with: 'San Francisco County'
      choose_for_question 'Yes', text: 'arrest made'
      choose_for_question 'No', text: 'crime report'
      choose 'In Custody Event'
      choose 'Out to Court'
      fill_in 'civilians involved', with: 1
      fill_in 'officers involved', with: 1
      click_button 'Save and Continue'

      expect(current_path).to match(%r{\/involved_civilians(\/new)?})
      choose_for_question 'No', text: 'assaulted officer'
      choose_for_question 'In custody', text: 'arrested and / or in custody'
      fill_in 'highest charge', with: 'Fake Charge 1234'
      choose_for_question 'Yes', text: 'perceived armed'
      check_for_question 'Other dangerous weapon', text: 'Type of weapon'
      choose_for_question 'Yes', text: 'confirmed armed'
      check_for_question 'Firearm', text: 'Weapons'
      check_for_question 'Rifle', text: 'Firearm types'
      choose_for_question 'Yes', text: 'resisted'
      choose_for_question 'Assaultive', text: 'highest level of active resistance'
      choose_for_question 'Yes', text: 'force used on this civilian'
      check 'Electronic control device'
      check 'Head'
      check 'Signs of alcohol impairment'
      choose_for_question 'Yes', text: 'injured'
      choose_for_question 'Serious bodily injury', text: 'Civilian injury level'
      check 'Abrasion/Laceration'
      choose_for_question 'Admitted to hospital - critical injuries', text: 'aid received'
      choose_for_question 'Yes', text: 'pre-existing condition'
      choose 'Female'
      select '10-17', from: 'age'
      check 'White'
      check 'Asian / Pacific Islander'
      check 'Laotian'
      click_button 'Save and Continue'

      expect(current_path).to match(%r{\/involved_officers(\/new)?})
      choose_for_question 'Yes', text: 'used force against a civilian'
      check 'To prevent escape'
      choose_for_question 'Yes', text: 'assaulted by civilian'
      check 'Threat of firearm'
      check 'Rear upper torso/back'
      choose_for_question 'Yes', text: 'injured'
      choose 'Serious bodily injury'
      check 'Stabbing wound'
      choose 'Medical assistance - treated on scene'
      choose_for_question 'Yes', text: 'pre-existing condition'
      choose 'Female'
      select '18-20', from: 'age'
      check 'White'
      check 'Asian / Pacific Islander'
      check 'Vietnamese'
      choose_for_question 'Yes', text: 'on duty'
      choose_for_question 'Patrol Uniform', text: 'dress'
      choose 'Sworn officer'
      click_button 'Save and Continue'

      expect(current_path).to end_with('/review')
      find_button('Send for review').click
    end

    it 'creates an incident that is visible from dashboard' do
      new_incident
      answer_all_screener submit: true
      visit_status :draft
      expect(page).to have_content('Edit')
    end

    it 'sets the ori and department automatically' do
      new_incident
      answer_all_screener submit: true
      expect(Incident.first.ori).to eq(@user.ori)
      expect(Incident.first.department).to eq(@user.department)
    end

    it 'shows all filled-out civilians and officers on the review page' do
      create_partial_incident(:review, 3, 2)
      expect(current_path).to end_with('/review')

      (1..3).each do |i|
        expect(page).to have_content("Civilian ##{i}")
      end
      (1..2).each do |i|
        expect(page).to have_content("Officer ##{i}")
      end
    end

    it 'disallows users from visiting steps that are not accessible yet' do
      def visit_step(step)
        visit(%r{\/incidents\/[0-9a-f\-]*\/}.match(current_path).to_s + step)
      end

      new_incident
      answer_all_screener submit: true

      expect(current_path).to end_with('/general_info')
      visit_step('involved_civilians')
      expect(current_path).to end_with('/general_info')
      visit_step('involved_officers')
      expect(current_path).to end_with('/general_info')
      visit_step('review')
      expect(current_path).to end_with('/general_info')

      answer_all_general_info submit: true

      expect(current_path).to end_with('/involved_civilians/new')
      visit_step('involved_officers')
      expect(current_path).to end_with('/involved_civilians/new')
      visit_step('review')
      expect(current_path).to end_with('/involved_civilians/new')

      answer_all_civilian submit: true

      expect(current_path).to end_with('/involved_officers/new')
      visit_step('review')
      expect(current_path).to end_with('/involved_officers/new')
    end

    it 'help button and feedback page work correctly', driver: :poltergeist do
      Feedback.create_table
      expect(Feedback.count).to eq(0)

      new_incident
      click_link('helpButton')
      # Should open in new tab
      expect(windows.length).to eq(2)

      page.within_window windows.last do
        expect(current_path).to end_with('/feedback')

        fill_in 'feedback[source]', with: "Foo"
        # Deliberately don't fill out the second field, ensure it throws an error.
        click_button 'Submit Feedback'
        expect(current_path).to end_with('/feedback')

        fill_in 'feedback[content]', with: "Bar"
        click_button 'Submit Feedback'
        expect(current_path).to end_with('/thank_you')
      end

      expect(Feedback.count).to eq(1)
      f = Feedback.first
      expect(f.source).to eq("Foo")
      expect(f.content).to eq("Bar")
    end

    it 'displays the Help button on the right pages'  do
      visit "/feedback"
      expect(page).to have_no_css('#helpButton')
      visit dashboard_path
      expect(page).to have_css('#helpButton')
      new_incident
      expect(page).to have_css('#helpButton')
      answer_all_screener submit: true
      expect(page).to have_css('#helpButton')
      answer_all_general_info submit: true
      expect(page).to have_css('#helpButton')
      answer_all_civilian submit: true
      expect(page).to have_css('#helpButton')
      answer_all_officer submit: true
      expect(current_path).to end_with('/review')
      expect(page).to have_css('#helpButton')
    end

    it 'shows the right counts by all filter options on the dashboard' do
      create_complete_incident
      create_partial_incident :review
      statuses = [nil, :draft, :in_review, :approved]
      statuses.each do |s|
        if s.nil?
          visit root_path
        else
          find("li.status-link-#{s} a").click
          expect(current_url).to end_with("/#{s}")
        end
        expect(status_nav_count(:draft)).to eq(1)
        expect(status_nav_count(:in_review)).to eq(1)
        expect(status_nav_count(:approved)).to eq(0)
      end
    end

    it 'allows navigation by breadcrumbs' do
      def breadcrumbs_classes
        all('#breadcrumbs a').map { |c| c[:class] }
      end

      new_incident

      expect(breadcrumbs_classes).to eq(%w(active disabled disabled disabled disabled))

      answer_all_screener submit: true

      expect(breadcrumbs_classes).to eq(%w(disabled active disabled disabled disabled))

      answer_all_general_info submit: true, num_civilians: 2

      expect(breadcrumbs_classes).to eq(%w(disabled enabled active disabled disabled))

      all('#breadcrumbs a')[1].click

      expect(breadcrumbs_classes).to eq(%w(disabled active enabled disabled disabled))

      all('#breadcrumbs a')[2].click

      expect(breadcrumbs_classes).to eq(%w(disabled enabled active disabled disabled))
    end

    it 'tracks all changes in the audit log' do
      create_partial_incident(:review, 2, 1)

      expect(current_path).to end_with('/review')
      expect(page).to have_content("Change History")
      expect(page).to have_css('.audit-entry', count: 5) # (screener + general info + 2 civilians + 1 officer)
      expect(page).to have_no_css('.audit-entry li')
      expect(page).to have_text('filled out the screener')

      find_link("Officers").click
      check 'Hispanic'
      choose 'Male'
      find('button[type=submit]').click

      expect(current_path).to end_with('/review')
      expect(page).to have_css('.audit-entry', count: 6)
      expect(page).to have_css('.audit-entry li', count: 2)
      expect(page).to have_text('gender from Female to Male')
      expect(page).to have_text('race from ["White"] to ["Hispanic", "White"]')

      # Let's "delete" a civilian, and make sure that (a) this is tracked in the audit log,
      # and (b) the InvolvedCivilian is removed from the incident but not actually deleted.

      find_link("General").click
      fill_in 'civilians involved', with: 1
      find('button[type=submit]').click

      expect(current_path).to end_with('/review')
      expect(page).to have_css('.audit-entry', count: 8)
      expect(page).to have_css('.audit-entry li', count: 3)
      expect(page).to have_text('num_involved_civilians from 2 to 1')
      expect(page).to have_text('deleted civilian')

      expect(Incident.first.involved_civilians.length).to eq(1)
      expect(InvolvedCivilian.count).to eq(2)
    end

    it 'does not destroy incidents on delete - just updates their status and makes them invisible' do
      create_partial_incident :review
      visit_status :draft
      expect(status_nav_count(:draft)).to eq(1)
      expect(Incident.count).to eq(1)
      changes_before = AuditEntry.count

      click_button 'Delete'

      expect(current_url).to end_with('/dashboard/draft')
      expect(status_nav_count(:draft)).to eq(0)
      expect(Incident.count).to eq(1)
      expect(Incident.first.status).to eq('deleted')
      # Be sure this is logged in the change history
      expect(AuditEntry.count).to eq(changes_before + 1)
    end
  end

  describe '[with multiple users]' do
    before :each do
      roles = Rails.configuration.x.roles
      @alice = create(:dummy_user, first_name: "Alice", last_name: "Anderson", email: "alice@example.com", role: roles.user, user_id: 'alice')
      @bob = create(:dummy_user, first_name: "Bob", last_name: "Bobberson", email: "bob@example.com", role: roles.user, user_id: 'bob')
      @claire = create(:dummy_user, first_name: "Claire", last_name: "Clarinet", email: "claire@example.com", role: roles.admin, user_id: 'claire')
      @dan = create(:dummy_user, first_name: "Dan", last_name: "Danish", email: "dan@example.com", role: roles.admin, ori: "another_ori", user_id: 'dan')
    end

    it 'allows users to only see authorized incidents' do
      login(user: @alice)
      create_partial_incident :review
      create_complete_incident
      # Alice can see her own incidents
      expect(status_nav_count(:draft)).to eq(1)
      expect(status_nav_count(:in_review)).to eq(1)
      logout

      # Bob can't see Alice's incidents
      login(user: @bob)
      expect(status_nav_count(:draft)).to eq(0)
      expect(status_nav_count(:in_review)).to eq(0)
      # But he can see his own
      create_partial_incident :review
      create_complete_incident
      expect(status_nav_count(:draft)).to eq(1)
      expect(status_nav_count(:in_review)).to eq(1)
      logout

      # Alice can't see Bob's new incidents
      login(user: @alice)
      expect(status_nav_count(:draft)).to eq(1)
      expect(status_nav_count(:in_review)).to eq(1)
      logout

      # Claire (the admin) can see BOTH of their complete incidents,
      # but neither of their incomplete incidents.
      login(user: @claire)
      expect(status_nav_count(:draft)).to eq(0)
      expect(status_nav_count(:in_review)).to eq(2)
      # Claire can see and review her own incidents
      create_partial_incident :review
      create_complete_incident
      expect(status_nav_count(:draft)).to eq(1)
      expect(status_nav_count(:in_review)).to eq(3)
      logout

      # Alice can't see Claire's incidents
      login(user: @alice)
      expect(status_nav_count(:draft)).to eq(1)
      expect(status_nav_count(:in_review)).to eq(1)
      logout

      # Bob can't see Claire's incidents
      login(user: @bob)
      expect(status_nav_count(:draft)).to eq(1)
      expect(status_nav_count(:in_review)).to eq(1)
      logout

      # Dan can't see anyone's incidents
      login(user: @dan)
      expect(status_nav_count(:draft)).to eq(0)
      expect(status_nav_count(:in_review)).to eq(0)
      logout
    end

    it 'lets an administrator edit another employee\'s incident' do
      login(user: @alice)
      create_complete_incident
      logout

      login(user: @claire)
      visit_status :in_review
      find('a', text: 'View').click
      expect(current_path).to end_with('/review')
      expect(page).to have_content('White')
      expect(page).to have_no_content('Cambodian')

      find('h1', text: 'Officer').find('~a', text: 'Edit').click
      expect(current_path).to end_with('/involved_officers/0/edit')
      check 'Cambodian'
      click_button 'Save and Continue'
      expect(page).to have_content('White')
      expect(page).to have_content('Cambodian')
    end

    it 'lets an administrator see who has drafts underway and how many, but not view them' do
      login(user: @alice)
      create_partial_incident :review
      create_partial_incident :review
      logout

      login(user: @claire)
      new_incident
      answer_all_screener submit: true
      visit root_path
      expect(status_nav_count(:draft)).to eq(1)
      expect(page).to have_content("Employees in your ORI also have 2 incidents that are not yet ready")
      expect(page).to have_content("Alice Anderson is still filling out 2 drafts")
    end

    it 'non-admins can edit incidents before, but not after, sending for review' do
      login(user: @alice)
      create_partial_incident :review, 2, 2
      expect(current_path).to end_with('/review')
      expect(page).to have_css('.review-edit')
      expect(page).to have_css('.review-delete')
      expect(page).to have_css('#breadcrumbs .enabled')

      find_button('Send for review').click
      visit_status :in_review
      find('a', text: 'View').click
      expect(current_path).to end_with('/review')
      expect(page).to have_no_css('.review-edit')
      expect(page).to have_no_css('.review-delete')
      expect(page).to have_no_css('#breadcrumbs .enabled')
    end

    it 'admins can edit others\' incidents after they are submitted for review' do
      login(user: @alice)
      create_complete_incident 2, 2
      logout

      login(user: @claire)
      visit_status :in_review
      find('a', text: 'View').click
      expect(current_path).to end_with('/review')

      expect(page).to have_css('.review-edit')
      expect(page).to have_css('.review-delete')
      expect(page).to have_css('#breadcrumbs .enabled')
    end

    it 'lets admins view basic statistics', driver: :poltergeist do
      def seriously_injured!(person)
        person.update_attributes(injured: true, injury_level: 'Serious bodily injury', injury_type: ['Contusion'],
                                 injury_from_preexisting_condition: false, medical_aid: 'Medical assistance - treated at facility and released')
      end

      login(user: @claire)

      # Create 6 incidents with 2 officer injuries and 3 civilian injuries.
      create :incident
      create_list(:incident, 2).map { |i| seriously_injured! i.involved_officers.first }
      create_list(:incident, 3).map { |i| seriously_injured! i.involved_civilians.first }

      visit dashboard_path(status: :analytics, year: Time.current.year - 1)

      # Test Key Metrics.
      expect(page).to have_text('6 total incidents')
      expect(page).to have_text('2 total officers seriously injured/deceased')
      expect(page).to have_text('3 total civilians seriously injured/deceased')

      # Test Incidents by Month chart.
      chart_bars = page.evaluate_script("Chartkick.charts['chart-1'].data[0].data").to_h
      incident_months = Incident.all.map(&:month)  # i.month is an integer from 1 to 12

      expect(chart_bars.keys).to eq(%w(January February March April May June July August September October November December))
      expect(chart_bars.values.inject(:+)).to eq(6)
      chart_bars.values.each_with_index { |count, idx| expect(count).to eq(incident_months.count(idx + 1)) }  # idx is an integer from 0 to 11
    end
  end
end
