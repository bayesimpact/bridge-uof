module Helpers
  # New visitors see a splash page that must be dismissed.

  # Visits the splash page and clicks the "ENTER" button. Should dismiss
  # the splash page, setting a cookie to prevent it from showing again.
  def handle_splash
    visit welcome_path
    click_button('ENTER')
  end

  def set_cookie(k, v)
    if page.driver.instance_of? Capybara::Poltergeist::Driver
      page.driver.set_cookie(k, v)
    else
      page.driver.browser.set_cookie("#{k}=#{v}")
    end
  end

  def clear_cookies
    if page.driver.instance_of? Capybara::Poltergeist::Driver
      page.driver.clear_cookies
    else
      page.driver.browser.clear_cookies
    end
  end

  def login(options = {})
    if Rails.configuration.x.login.use_siteminder?
      login_with_siteminder(options)
    elsif Rails.configuration.x.login.use_devise?
      login_with_devise(options)
    else
      raise "Login mechanism should be set to either Devise or Siteminder"
    end
  end

  def logout
    if Rails.configuration.x.login.use_siteminder?
      clear_cookies
    elsif Rails.configuration.x.login.use_devise?
      page.driver.submit :delete, destroy_user_session_path, {}
    else
      raise "Login mechanism should be set to either Devise or Siteminder"
    end
  end

  # Creates a valid Siteminder cookie for the user, allowing automatic login.
  def login_with_siteminder(options = {})
    expect(Rails.configuration.x.login.use_siteminder?).to be true
    user = options[:user] || (build :dummy_user)
    cookie_params = {
      'givenname' => user.first_name,
      'sn' => user.last_name,
      'mail' => user.email,
      'dojORI' => user.ori,
      'dojagencyName' => user.department,
      'SM_USERLOGINNAME' => user.user_id,
      'SM_USERGROUPS' => Siteminder.encode_role(user.role)
    }
    cookie_str = cookie_params.map { |k, v| "#{k}=#{v}" }.join(';')
    @encrypted_cookie = Siteminder.encrypt_cookie(
      cookie_str,
      Rails.configuration.x.login.siteminder_decrypt_key,
      Rails.configuration.x.login.siteminder_decrypt_init_v,
      url_escape: true
    )
    set_cookie("SMOFC", @encrypted_cookie)
    handle_splash unless options[:dont_handle_splash]
  end

  # Logs in with a valid user.
  def login_with_devise(options = {})
    expect(Rails.configuration.x.login.use_devise?).to be true
    user = options[:user] || (create :dummy_user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    find('input[type=submit]').click
    handle_splash unless options[:dont_handle_splash]
  end

  # Chooses a response to a multiple choices question defined as a text in a
  # label grouped with a set of radio buttons.
  def choose_for_question(choice, options = {})
    within(options[:locator] || 'div.form-group', text: options[:text]) do
      expect(page).to have_content(options[:text])
      choose choice
    end
  end

  # Answers all required questions in the screener page. By default it uses
  # answers that would require to report an incident.
  def answer_all_screener(options = {})
    expect(current_path).to end_with('/screener')
    expect(page).to have_content('Do I need to file this incident')
    choose_for_question options[:multiple_agencies?] || 'No', text: 'multiple agencies'
    choose_for_question options[:firearms_discharged?] || 'Yes', text: 'firearms discharged'

    click_button 'Save and Continue' if options[:submit]
  end

  # Answers all required questions in the general info page. By default it uses
  # answers that would create a valid incident.
  def answer_all_general_info(options = {})
    expect(current_path).to end_with('/general_info')
    expect(page).to have_content('General Incident Information')
    # Default to creating an incident for last year, so it'll be included
    # with any state submission done today.
    today = Time.zone.today
    default_date = Date.new(today.year - 1, today.month, today.day)
    fill_in 'Date', with: options[:date] || default_date.strftime('%m/%d/%Y')
    fill_in 'Time', with: options[:time] || '1830'
    fill_in 'Incident Address', with: options[:address] || '1355 Market St'
    fill_in 'City', with: options[:city] || 'San Francisco'
    fill_in 'State', with: options[:state] || 'CA'
    fill_in 'Zip', with: options[:zip_code] || '94103'
    fill_in 'County', with: options[:county] || 'San Francisco County'
    choose_for_question(options[:was_an_arrest_made?] || 'Yes', text: 'arrest made')
    choose_for_question(options[:result_in_crime_report?] || 'No', text: 'crime report')
    choose 'Welfare Check'
    fill_in 'civilians involved', with: options[:num_civilians] || 1
    fill_in 'officers involved', with: options[:num_officers] || 1

    click_button 'Save and Continue' if options[:submit]
  end

  # Answers all required questions in a "Civilian Involved" page.
  def answer_all_civilian(options = {})
    expect(current_path).to match(%r{\/involved_civilians(\/new)?})
    choose_for_question options[:assaulted_officer?] || 'No', text: 'assaulted officer'
    choose_for_question options[:custody_status] || 'In custody', text: 'arrested and / or in custody'
    fill_in 'highest charge', with: options[:highest_charge] || 'Fake charge 123'
    choose_for_question options[:perceived_armed?] || 'No', text: 'perceived armed'
    choose_for_question options[:confirmed_armed?] || 'No', text: 'confirmed armed'
    choose_for_question options[:resisted?] || 'No', text: 'resisted'
    choose_for_question options[:received_force?] || 'No', text: 'force used on this civilian'
    if options[:received_force?] == 'Yes'
      check options[:received_force_type] || 'Electronic control device'
      check options[:received_force_location] || 'Head'
    end
    check 'Signs of alcohol impairment'
    choose_for_question options[:injured?] || 'No', text: 'injured'
    choose options[:gender] || 'Female'
    select (options[:age] || '10-17'), from: 'age'
    if options[:race]
      options[:race].each do |race|
        check race
      end
    else
      check 'White'
    end

    click_button 'Save and Continue' if options[:submit]
  end

  # Answers all required questions in a "Officer Involved" page.
  def answer_all_officer(options = {})
    expect(current_path).to match(%r{\/involved_officers(\/new)?/})
    choose_for_question options[:used_force?] || 'No', text: 'used force against a civilian'
    choose_for_question options[:assaulted_by_civilian?] || 'No', text: 'assaulted by civilian'
    choose_for_question options[:injured?] || 'No', text: 'injured'
    choose options[:gender] || 'Female'
    select (options[:age] || '18-20'), from: 'age'
    if options[:race]
      options[:race].each do |race|
        check race
      end
    else
      check 'White'
    end
    choose_for_question options[:on_duty?] || 'Yes', text: 'on duty'
    choose_for_question options[:dress] || 'Patrol Uniform', text: 'dress'
    choose_for_question options[:sworn_type] || 'Sworn officer', text: 'Officer type'

    click_button 'Save and Continue' if options[:submit]
  end

  # Creates a new incident and goes to the first page of the creation flow.
  def new_incident
    find('#new-incident').click
  end

  # Start a new incident, and fill out all the pages up to (but not
  # including) stop_step, which should be one of the elements of Incident::STEPS.
  def create_partial_incident(stop_step, num_civilians = 1, num_officers = 1, general_info = {})
    expect(Incident::STEPS).to include stop_step

    new_incident
    return if stop_step == :screener

    answer_all_screener submit: true
    return if stop_step == :general

    general_info.reverse_merge!(submit: true, num_civilians: num_civilians, num_officers: num_officers)
    answer_all_general_info(general_info)
    return if stop_step == :civilians

    num_civilians.times do
      answer_all_civilian submit: true
    end
    return if stop_step == :officers

    num_officers.times do
      answer_all_officer submit: true
    end
    expect(stop_step).to be :review
  end

  # Create a new incident, fill out all pages, and send for supervisor review.
  def create_complete_incident(num_civilians = 1, num_officers = 1, general_info = {})
    create_partial_incident(:review, num_civilians, num_officers, general_info)
    expect(current_path).to end_with('/review')
    find_button('Send for review').click
  end

  def create_and_review_incident
    create_complete_incident
    visit_status :in_review
    click_link 'View'
    click_button 'Mark as reviewed'
  end

  def submit_to_state
    visit_status :state_submission
    click_button 'FINAL SUBMISSION'
  end

  # Visit the dashboard page showing incidents of the given status
  def visit_status(s)
    visit dashboard_path(status: s).to_s
  end

  def status_nav_count(status)
    expect(Incident::STATUS_TYPES).to include status
    text = find('li.status-link-' + status.to_s).text
    text[(text.index('(') + 1)..(text.index(')') - 1)].to_i
  end

  def visit_status_count_incidents(status)
    visit_status status
    all('tbody tr').length
  end
end
