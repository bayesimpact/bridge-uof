require 'rails_helper'

describe '[Monitoring endpoints, no login]', type: :request do
  it '/ping.html renders "pong"' do
    visit '/ping.html'
    expect(page.status_code).to eq(200)
    expect(page.body).to eq("pong")
  end

  it '/ping renders "pong"' do
    visit 'ping'
    expect(page.status_code).to eq(200)
    expect(page.body).to eq("pong")
  end
end
