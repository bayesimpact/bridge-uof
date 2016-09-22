# These rake tasks let you encrypt/decrypt Siteminder cookies.
# Useful for setting cookies you want to use in dev/testing, and
# for debugging.
require 'cgi'
require "#{Rails.root}/lib/siteminder"

# Reads an environment variable file and imports settings to ENV
def import_env_variables(env_file)
  if env_file.present?
    File.open(env_file, "r") do |f|
      f.each_line do |line|
        parts = line.split("=", 2)
        parts << ""
        ENV[parts[0]] = parts[1]
      end
    end
  else
    puts "env_file is nil -- skipping importing env variables"
  end
end

namespace :siteminder do
  desc "Encrypt an SMOFC cookie"
  task :encrypt_cookie, :cookie_str, :env_file do |_, args|
    cookie_str = args[:cookie_str]
    puts "Encrypting SMOFC cookie '#{cookie_str}' for siteminder"

    env_file = args.env_file
    import_env_variables(env_file)

    hash = Siteminder.parse_cookie_str_to_hash(cookie_str)
    puts "Parsed cookie as: " + hash.to_s

    encrypted = Siteminder.encrypt_cookie(cookie_str,
                                          ENV["SITEMINDER_DECRYPT_KEY"],
                                          ENV["SITEMINDER_DECRYPT_INIT_V"])
    puts "Encrypted + URL escaped (to paste into your browser e.g. EditThisCookie):"
    puts "*" * 40
    puts CGI.escape(encrypted)
    puts "*" * 40
    puts "(Remember, the cookie key is SMOFC)"
  end

  desc "Decrypt an SMOFC cookie"
  task :decrypt_cookie, :cookie_str, :env_file do |_, args|
    cookie_str = args[:cookie_str]
    puts "Decrypting SMOFC cookie '#{cookie_str}'"
    cookie_str = CGI.unescape(cookie_str)

    env_file = args.env_file
    import_env_variables(env_file)

    decrypted = Siteminder.decrypt_cookie(cookie_str,
                                          ENV["SITEMINDER_DECRYPT_KEY"],
                                          ENV["SITEMINDER_DECRYPT_INIT_V"])
    puts "Decrypted cookie: " + decrypted
  end
end
