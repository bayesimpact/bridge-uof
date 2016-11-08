require 'cgi'
require 'rails_helper'

describe "[Siteminder cryptography module]", type: :request do
  let(:key) { Rails.configuration.x.login.siteminder_decrypt_key }
  let(:init_v) { Rails.configuration.x.login.siteminder_decrypt_init_v }

  let(:test_cookie) { "foo=bar;baz=qux" }
  let(:test_cookie_encrypted) { "dVvfJ8m0W+EBJ29NnoHbEQ==" }
  let(:test_cookie_encrypted_escaped) { CGI.escape(test_cookie_encrypted) }

  it 'encrypts correctly' do
    expect(Siteminder.encrypt_cookie(test_cookie, key, init_v)).to eq(test_cookie_encrypted)
    expect(Siteminder.encrypt_cookie(test_cookie, key, init_v, true)).to eq(test_cookie_encrypted_escaped)
  end

  it 'decrypts correctly' do
    expect(
      Siteminder.decrypt_cookie(test_cookie_encrypted, key, init_v)
    ).to eq(test_cookie)

    expect(
      Siteminder.decrypt_cookie(test_cookie_encrypted_escaped, key, init_v, true)
    ).to eq(test_cookie)
  end

  it 'does a two-way encrypt-decrypt correctly' do
    # Generate a random 16-character cookie
    random_cookie = (0...16).map { (65 + rand(26)).chr }.join

    expect(
      Siteminder.encrypt_decrypt_cookie(random_cookie, key, init_v)
    ).to eq(random_cookie)
  end

  it 'parse_cookie_string_to_hash on basic test cookie' do
    h = Siteminder.parse_cookie_str_to_hash(test_cookie)
    expect(h).to be_a_kind_of(Hash)
    expect(h.length).to eq(2)
    expect(h["foo"]).to eq("bar")
    expect(h["baz"]).to eq("qux")
  end

  it 'parse_cookie_string_to_hash on empty cookie returns empty hash' do
    h = Siteminder.parse_cookie_str_to_hash("")
    expect(h).to be_a_kind_of(Hash)
    expect(h).to be_empty
  end

  it 'parse_cookie_string_to_hash on skips bad cookie values' do
    h = Siteminder.parse_cookie_str_to_hash("foo=bar;baz;qux")
    expect(h).to be_a_kind_of(Hash)
    expect(h.length).to eq(1)
    expect(h["foo"]).to eq("bar")
  end

  it 'extracts the user role from the complex LDAP field' do
    expect(Siteminder.extract_role('')).to be nil
    expect(Siteminder.extract_role('cn')).to be nil
    expect(Siteminder.extract_role('cn=')).to eq('')
    expect(Siteminder.extract_role('cn=foo')).to eq('foo')
    expect(Siteminder.extract_role('a=x,cn=Bar,b=y,c=z')).to eq('Bar')
  end

  it 'encodes a user role into a valid LDAP field' do
    expect(Siteminder.encode_role(nil)).to eq('cn=')
    expect(Siteminder.encode_role('')).to eq('cn=')
    expect(Siteminder.encode_role('admin')).to eq('cn=admin')
    expect(Siteminder.encode_role('foo,bar,baz')).to eq('cn=foo,bar,baz')
  end

  it 'extracts the user ORI from the dojORI field' do
    expect(Siteminder.extract_ori('')).to be nil
    expect(Siteminder.extract_ori('CA01234')).to eq('CA01234')
    expect(Siteminder.extract_ori('   CA01234   ')).to eq('CA01234')
    expect(Siteminder.extract_ori('Foo Police Dept - CA01234')).to eq('CA01234')
    expect(Siteminder.extract_ori('Foo - Police - Dept -- CA01234')).to eq('CA01234')
  end
end
