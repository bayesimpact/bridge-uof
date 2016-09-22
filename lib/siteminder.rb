require 'base64'
require 'openssl'
require 'cgi'

# This module allows the encryption/decryption of data in the same
# fashion as DOJ's Siteminder auth server. Needed in a production environment
# where authentication is done via a proxy Siteminder auth server, which
# then passes an encrypted cookie to this app. This code lets us decrypt
# the cookie so we can read the user's information.
module Siteminder
  def self.run_algorithm(str, encrypt, key, init_v)
    des = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC')
    des.key = [key].pack('H*')
    des.iv = [init_v].pack('H*')
    if encrypt
      des.encrypt
    else
      des.decrypt
    end
    des.update(str) + des.final
  end

  def self.encrypt_cookie(str, key, init_v, url_escape = false)
    str = run_algorithm(str, true, key, init_v)
    str = Base64.strict_encode64(str)
    str = CGI.escape(str) if url_escape
    str
  end

  def self.decrypt_cookie(str, key, init_v, url_escape = false)
    # Cookies arrive Base64-encoded
    str = CGI.unescape(str) if url_escape
    str = Base64.strict_decode64(str)
    run_algorithm(str, false, key, init_v)
  end

  def self.encrypt_decrypt_cookie(str, key, init_v, url_escape = false)
    encrypted = encrypt_cookie(str, key, init_v, url_escape)
    decrypt_cookie(encrypted, key, init_v, url_escape)
  end

  def self.parse_cookie_str_to_hash(str)
    str.split(";")
       .select { |part| part.include? '=' }
       .map { |part| [part.split('=', 2)[0], part.split('=', 2)[1]] }
       .to_h
  end

  def self.extract_role(str)
    str.split(',')
       .find { |part| part.start_with? 'cn=' }
       .try { |role| role.split('=', 2)[1] }
  end

  def self.encode_role(role)
    "cn=#{role}"
  end

  def self.extract_ori(str)
    str.split('-').last.strip if str.present?
  end
end
