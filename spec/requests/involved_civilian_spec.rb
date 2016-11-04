require 'rails_helper'

describe '[Involved Civilian Page]', type: :request do
  before :each do
    login
  end

  describe '[incident with one civilian]' do
    before :each do
      create(:incident, stop_step: :civilians)
      visit incident_path(Incident.first)
      expect(current_path).to end_with('involved_civilians/new')
    end

    it 'is linked directly from dashboard' do
      visit_status :draft
      find('a', text: 'Edit').click
      expect(current_path).to end_with('involved_civilians/new')
    end

    it 'requires answers before continuing' do
      find('button[type=submit]').click
      expect(current_path).to end_with('/involved_civilians')
      expect(page).to have_content('There were problems with your form')
    end

    it 'continues to the next page if the data is valid' do
      answer_all_civilian submit: true

      expect(current_path).not_to end_with('/involved_civilians')
      expect(page).to have_no_content('There were problems with your form')
    end

    it 'does not display numerical links to individual civilians' do
      links = all('a.person-link')
      expect(links.length).to eq(0)
    end

    it 'if civilian flees, clear the appropriate sub-questions (see InvolvedCivilian model)' do
      answer_all_civilian submit: true, custody_status: 'Fled'
      expect(InvolvedCivilian.first.injured).to be nil
    end

    it 'if civilian does not flee, does not clear those sub-questions' do
      answer_all_civilian submit: true, custody_status: 'In custody (W&I section 5150)'
      expect(InvolvedCivilian.first.injured).to be false
    end

    it 'if civilian is booked, require highest charge field' do
      InvolvedCivilian::CUSTODY_STATUSES_BOOKED.each do |status|
        answer_all_civilian submit: true, custody_status: status, highest_charge: ''
        expect(page).to have_content('There were problems with your form')
      end
      answer_all_civilian(submit: true, highest_charge: 'Fake Charge 1234',
                          custody_status: InvolvedCivilian::CUSTODY_STATUSES_BOOKED[0])
      expect(page).to have_no_content('There were problems with your form')
    end

    it 'requires a firearm type, if appropriate', driver: :poltergeist do\
      answer_all_civilian confirmed_armed?: 'Yes'
      within "#confirmed_armed_weapon_question" do
        check 'Firearm'
      end

      # Should fail since firearm type not specified
      find('button[type=submit]').click
      expect(current_path).to end_with('/involved_civilians')
      expect(page).to have_content('There were problems with your form')

      # Should succeed
      check 'Rifle'
      find('button[type=submit]').click
      expect(current_path).not_to end_with('/involved_civilians')
      expect(page).to have_no_content('There were problems with your form')
    end

    it 'allows partial save', driver: :poltergeist do
      select '10-17', from: 'age'
      click_link "I'm not done yet"

      expect(current_path).to eq('/dashboard')

      visit_status :draft
      click_link 'Edit'

      expect(current_path).to end_with('/involved_civilians/0/edit')
      expect(page).to have_no_content('There were problems with your form')
      expect(page).to have_field("age", with: "10-17")
    end

    it "moves to the next page iff Save and Continue is clicked", driver: :poltergeist do
      # Even when all the questions are filled out, the Screener should still be
      # considered 'invalid' when partial=true.
      answer_all_civilian
      click_link "I'm not done yet"
      visit_status :draft
      click_link 'Edit'

      expect(current_path).to end_with('/involved_civilians/0/edit')

      click_button "Save and Continue"

      expect(current_path).to end_with('/involved_officers/new')
    end

    it 'correctly records unchecked options when all boxes get unchecked', driver: :poltergeist do
      answer_all_civilian perceived_armed?: 'Yes'
      within "#perceived_armed_weapon_question" do
        check 'Firearm'
      end

      find('button[type=submit]').click

      expect(current_path).not_to end_with('/involved_civilians')
      expect(page).to have_no_content('There were problems with your form')

      # Go back to editing the page.
      click_link 'Civilians'
      expect(current_path).to end_with('/involved_civilians/0/edit')
      within "#perceived_armed_weapon_question" do
        uncheck 'Firearm'
      end

      find('button[type=submit]').click

      expect(page).to have_content('There were problems with your form')
    end

    describe '[order-of-force]', driver: :poltergeist do
      before :each do
        answer_all_civilian submit: false

        choose_for_question 'Yes', text: 'force used on this civilian'
        check 'Blunt / impact weapon'
        check 'Discharge of firearm (miss)'
        check 'K-9 contact'
        check 'Front upper torso/chest'
      end

      it 'displays a list of types of force instead of an order on the Review page if no order is given' do
        find('button[type=submit]').click
        answer_all_officer submit: true

        expect(current_path).to end_with('/review')
        expect(page).to have_content('Blunt / impact weapon, Discharge of firearm (miss), K-9 contact')
      end

      it 'allows dragging the types of force and displays the order on the Review page if given' do
        check 'order-of-force-specified'
        page.find('.order-of-force li:nth-child(2)').drag_to page.find('.order-of-force li:nth-child(3)')
        page.find('.order-of-force li:nth-child(1)').drag_to page.find('.order-of-force li:nth-child(3)')
        find('button[type=submit]').click
        answer_all_officer submit: true

        expect(current_path).to end_with('/review')
        expect(page).to have_content('K-9 contact -> Discharge of firearm (miss) -> Blunt / impact weapon')

        # Go back and forth once to make sure the order persists.

        click_link 'Civilians'

        expect(page).to have_css('.order-of-force li', count: 3)

        find('button[type=submit]').click

        expect(current_path).to end_with('/review')
        expect(page).to have_content('K-9 contact -> Discharge of firearm (miss) -> Blunt / impact weapon')
      end
    end
  end

  describe '[incident with 3 civilians]' do
    before :each do
      create(:incident, num_civilians: 3, stop_step: :civilians)
      visit incident_path(Incident.first)
      expect(current_path).to end_with('involved_civilians/new')
    end

    it 'displays the right selectors to jump to different civilians' do
      links = all('a.person-link')
      expect(links.length).to eq(3)
      expect(links[0][:class]).to include 'person-link-current'
      expect(links[1][:class]).to include 'person-link-disabled'
      expect(links[2][:class]).to include 'person-link-disabled'

      answer_all_civilian submit: true

      links = all('a.person-link')
      expect(links.length).to eq(3)
      expect(links[0][:class]).not_to include 'person-link-disabled'
      expect(links[1][:class]).to include 'person-link-current'
      expect(links[2][:class]).to include 'person-link-disabled'

      links[0].click  # Go back to look at the first civilian

      links = all('a.person-link')
      expect(links.length).to eq(3)
      expect(links[0][:class]).to include 'person-link-current'
      expect(links[1][:class]).not_to include 'person-link-disabled'
      expect(links[2][:class]).to include 'person-link-disabled'
    end

    it "doesn't skip partially filled civilians", driver: :poltergeist do
      select '10-17', from: 'age'
      click_link "I'm not done yet"

      visit_status :draft
      click_link 'Edit'

      expect(current_path).to end_with('/involved_civilians/0/edit')
    end
  end

  it "orders 5 civilians correctly, by creation time" do
    create(:incident, num_civilians: 5, stop_step: :civilians)
    visit incident_path(Incident.first)
    expect(current_path).to end_with('involved_civilians/new')

    5.times do
      answer_all_civilian submit: true
    end
    expect(current_path).to end_with('involved_officers/new')

    click_link 'Civilians'
    expect(all('a.person-link').length).to eq(5)

    incident = Incident.first
    civilians_sorted = InvolvedPerson.sorted_persons(incident.involved_civilians)
    expect(civilians_sorted.map(&:created_at)).to be_sorted
  end
end
