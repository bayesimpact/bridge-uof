require 'rails_helper'

describe '[AdditionalSubmissionInformation with contracting ORI relationships]', type: :request do
  let(:roles) { Rails.configuration.x.roles }
  let(:parent_ori_user) { build(:dummy_user, email: "1@example.com", ori: 'PARENT_ORI', role: roles.user, user_id: 'parentuser') }
  let(:sub_ori_user) { build(:dummy_user, email: "2@example.com", ori: 'SUB_ORI', role: roles.user, user_id: 'subuser') }
  let(:valid_year) { Time.last_year.to_s }

  describe '[users of a non-contracting ORI]' do
    before(:each) do
      login(user: sub_ori_user)
    end

    describe 'create additional submission information' do
      before(:each) do
        visit '/additional_submission_informations/new'
      end

      it 'redirects to dashboard on successful entry' do
        expect(page).to have_content(sub_ori_user.ori)

        fill_in "Total number of K-9 officers in #{valid_year} that were seriously injured or killed.", with: 4
        fill_in "Total number of non-sworn uniformed employees or volunteers in #{valid_year} that were seriously injured or killed.", with: 1
        fill_in "Total number of non-sworn uniformed employees or volunteers in #{valid_year} that used force on a civilian, resulting in serious injury or death to the civilian.", with: 1
        click_button 'Submit'

        expect(page).to have_current_path('/dashboard/past_submissions')
      end
    end
  end

  describe '[users of a contracting ORI]' do
    before(:each) do
      login(user: parent_ori_user)
      create_partial_incident :general

      expect(page).to have_content('Which agency are you filling out this report on behalf of?')
      expect(page).to have_content('Our records indicate that your department provides policing services for 1 contract city')
      expect(page).to have_css('select option', count: 2)

      select "SUB_DEPT (SUB_ORI)"
      answer_all_general_info submit: true
    end

    it 'lists links to ORI' do
      visit new_additional_submission_information_path
      parent_ori_user.allowed_oris.each do |ori|
        click_link(ori)

        expect(page).to have_current_path(new_additional_submission_information_path(ori: ori))
        fill_in "Total number of K-9 officers in #{valid_year} that were seriously injured or killed.", with: 4
        fill_in "Total number of non-sworn uniformed employees or volunteers in #{valid_year} that were seriously injured or killed.", with: 1
        fill_in "Total number of non-sworn uniformed employees or volunteers in #{valid_year} that used force on a civilian, resulting in serious injury or death to the civilian.", with: 1
        click_button 'Submit'

        if ori == 'SUB_ORI'
          expect(page).to have_current_path('/dashboard/past_submissions')
        else
          expect(page).to have_current_path(new_additional_submission_information_path)
        end
      end
    end
  end
end
