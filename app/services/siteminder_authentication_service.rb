# SiteminderAuthenticationService.authenticate! handles Siteminder authentication.
class SiteminderAuthenticationService
  # Authenticates with Siteminder, returns the current user or throws an exception with a list of errors.
  def self.authenticate!(cookies)
    # Grab the cookie, ensure it's set
    encrypted_cookie = cookies[:SMOFC]
    if encrypted_cookie.blank?
      error_msg = "Siteminder cookie is #{encrypted_cookie.nil? ? 'nil' : 'missing'}"
      raise BridgeExceptions::SiteminderCookieNotFoundError.new(error_msg)
    end

    # Decrypt it (will be nil if an Exception is raised during encryption)
    decrypted = decrypt_cookie(encrypted_cookie)
    if decrypted.blank?
      raise BridgeExceptions::SiteminderAuthenticationError.new("Could not decrypt Siteminder (SMOFC) cookie.")
    end
    Rails.logger.debug cookie_to_str(decrypted)

    get_user_from_cookie(decrypted)
  end

  # "Private methods"

  def self.decrypt_cookie(encrypted_cookie)
    # The cookie is encrypted with a symmetric-key algorithm, then
    # base64 encoded.
    #
    # The DOJ Siteminder team uses some Java code to encrypt it with
    # Java cipher packages whose inner workings aren't fully clear,
    # but it's some kind of DES encryption variant (DESede/CBC/PKCS5Padding)
    # With some trial/error/googling, the code in lib/siteminder.rb
    # successfully decrypts it.
    #
    # The cookie contents itself follow Siteminder's Open Format Cookie
    # Ask @everett for more information.
    config = Rails.configuration.x.login
    cookie = Siteminder.decrypt_cookie(encrypted_cookie,
                                       config.siteminder_decrypt_key,
                                       config.siteminder_decrypt_init_v)
    Siteminder.parse_cookie_str_to_hash(cookie)
  rescue OpenSSL::Cipher::CipherError, ArgumentError => e
    Rails.logger.error("Error decrypting Siteminder cookie:\n\"#{encrypted_cookie}\"")
    Rails.logger.error(e.message)
    Rails.logger.error("Partial stack trace:")
    e.backtrace.each do |trace|
      Rails.logger.error("  " + trace) if trace.include? "application_controller.rb"
    end
    nil
  end

  def self.cookie_to_str(cookie)
    "Decrypted Siteminder cookie key/value pairs: \n" + cookie.map { |k, v| "  -- #{k}: #{v}" }.join("\n")
  end

  def self.get_user_from_cookie(decrypted_cookie)
    user_attributes = extract_user_attributes_from_cookie(decrypted_cookie)
    get_user_from_cookie_attributes(user_attributes)
  end

  def self.extract_user_attributes_from_cookie(decrypted_cookie)
    errors = []
    user_attributes = {}

    User::SITEMINDER_KEY_MAPPING.select do |k, v|
      if decrypted_cookie[k].blank?
        errors.push("'#{k}' field was #{decrypted_cookie[k].nil? ? 'nil' : 'blank'}")
      else
        user_attributes[v] = decrypted_cookie[k]
      end
    end

    raise BridgeExceptions::SiteminderAuthenticationError.new(errors.join("\n")) if errors.present?

    # The "role" field comes from a cookie field that looks like
    # SM_USERGROUPS:cn=admin,ou=groups,dc=doj,dc=ca,dc=gov
    # (we just need the "admin" part)
    user_attributes[:role] = Siteminder.extract_role(user_attributes[:role])

    # The "ori" field has the department name, then a dash, then the ori.
    # E.g. dojORI=FOO POLICE DEPT-CA0123456 (we want the "CA0123456" part)
    user_attributes[:ori] = Siteminder.extract_ori(user_attributes[:ori])

    user_attributes
  end

  def self.get_user_from_cookie_attributes(user_attributes)
    # Log the user in by email
    user = User.where(user_id: user_attributes[:user_id]).first || User.create(user_attributes)
    user.update_attributes(user_attributes) unless user == User.new(user_attributes)

    if user.errors.present?
      error_msgs = user.errors.messages
      raise BridgeExceptions::SiteminderAuthenticationError.new(error_msgs.map { |k, v| "#{k}: #{v}" }.join("\n"))
    end

    user
  end
end
