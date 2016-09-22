require 'rails_helper'

describe '[ActionController]', type: :controller do
  it "replace_url_host" do
    c = ApplicationController.new
    expect(c.replace_url_host('http://foo.bar.baz/qux', 'something')).to eq('something/qux')
    expect(c.replace_url_host('http://foo.bar.baz/qux', 'https://something')).to eq('https://something/qux')
    expect(c.replace_url_host('https://foo.bar.baz/qux', 'https://something')).to eq('https://something/qux')
    expect(c.replace_url_host('http://foo.bar.baz/', 'something')).to eq('something/')
    expect(c.replace_url_host('http://foo.bar.baz', 'something')).to eq('something')
  end
end
