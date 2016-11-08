require 'rails_helper'

# TODO: Combine this with the involved_civilian_spec, it's really identical.
describe '[Involved Officer Page]', type: :request do
  before :each do
    login
  end

  describe '[incident with one officer]' do
    before :each do
      create(:incident, stop_step: :officers)
      visit incident_path(Incident.first)
      expect(current_path).to end_with('involved_officers/new')
    end

    it 'is linked directly from dashboard' do
      visit_status :draft
      find('a', text: 'Edit').click
      expect(current_path).to end_with('involved_officers/new')
    end

    it 'requires answers before continuing' do
      find('button[type=submit]').click
      expect(current_path).to end_with('/involved_officers')
      expect(page).to have_content('There were problems with your form')
    end

    it 'continues to the next page if the data is valid' do
      answer_all_officer submit: true

      expect(current_path).not_to end_with('/involved_officers')
      expect(page).to have_no_content('There were problems with your form')
    end

    it 'does not display numberical links to individual officers' do
      links = all('a.person-link')
      expect(links.length).to eq(0)
    end
  end

  describe '[prepopulated fields]' do
    it 'prepopulates certain fields when there is only one officer' do
      create(:incident, stop_step: :civilians)
      visit incident_path(Incident.first)
      answer_all_civilian(assaulted_officer?: "No",
                          received_force?: "No", submit: true)
      expect(current_path).to end_with('/involved_officers/new')
      expect(find("#involved_officer_officer_used_force_true")).not_to be_checked
      expect(find("#involved_officer_officer_used_force_false")).to be_checked
      expect(find("#involved_officer_received_force_true")).not_to be_checked
      expect(find("#involved_officer_received_force_false")).to be_checked

      click_link 'Civilians'
      expect(current_path).to end_with('/involved_civilians/0/edit')
      answer_all_civilian(assaulted_officer?: "Yes",
                          received_force?: "Yes", submit: true)
      expect(current_path).to end_with('/involved_officers/new')
      expect(find("#involved_officer_officer_used_force_true")).to be_checked
      expect(find("#involved_officer_officer_used_force_false")).not_to be_checked
      expect(find("#involved_officer_received_force_true")).to be_checked
      expect(find("#involved_officer_received_force_false")).not_to be_checked

      # Ensure these "prepopulated" values don't override saved values.
      answer_all_officer submit: true  # Override prepopulated values
      expect(current_path).to end_with('/review')
      click_link 'Officers'
      expect(find("#involved_officer_officer_used_force_true")).not_to be_checked
      expect(find("#involved_officer_officer_used_force_false")).to be_checked
      expect(find("#involved_officer_received_force_true")).not_to be_checked
      expect(find("#involved_officer_received_force_false")).to be_checked
    end

    it 'does NOT prepopulate any fields when there is more than one officer' do
      create(:incident, stop_step: :civilians, num_officers: 2)
      visit incident_path(Incident.first)
      answer_all_civilian(assaulted_officer?: "Yes",
                          received_force?: "Yes", submit: true)
      expect(current_path).to end_with('/involved_officers/new')
      expect(find("#involved_officer_officer_used_force_true")).not_to be_checked
      expect(find("#involved_officer_officer_used_force_false")).not_to be_checked
      expect(find("#involved_officer_received_force_true")).not_to be_checked
      expect(find("#involved_officer_received_force_false")).not_to be_checked
    end
  end

  describe '[incident with 3 officers]' do
    before :each do
      create(:incident, stop_step: :officers, num_officers: 3)
      visit incident_path(Incident.first)
      expect(current_path).to end_with('involved_officers/new')
    end

    it 'displays the right selectors to jump to different officers' do
      links = all('a.person-link')
      expect(links.length).to eq(3)
      expect(links[0][:class]).to include 'person-link-current'
      expect(links[1][:class]).to include 'person-link-disabled'
      expect(links[2][:class]).to include 'person-link-disabled'

      answer_all_officer submit: true

      links = all('a.person-link')
      expect(links.length).to eq(3)
      expect(links[0][:class]).not_to include 'person-link-disabled'
      expect(links[1][:class]).to include 'person-link-current'
      expect(links[2][:class]).to include 'person-link-disabled'

      links[0].click  # Go back to look at the first officer

      links = all('a.person-link')
      expect(links.length).to eq(3)
      expect(links[0][:class]).to include 'person-link-current'
      expect(links[1][:class]).not_to include 'person-link-disabled'
      expect(links[2][:class]).to include 'person-link-disabled'
    end
  end
end
