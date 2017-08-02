# frozen_string_literal: true

require_relative '../lib/spellchecker_app'
require 'rack/test'

describe SpellcheckerApp do
  include Rack::Test::Methods

  def app
    SpellcheckerApp.new
  end

  def json_response
    JSON.parse(last_response.body)
  end

  it 'returns corrected query' do
    post '/', '{"query": "плптье женская"}'
    expect(last_response).to be_ok
    expect(json_response).to eq('result' => 'платье женская')
  end

  it 'does not accept get requests' do
    get '/', query: 'плптье женская'
    expect(last_response.status).to eq(400)
    expect(json_response['error']).to be_truthy
  end

  it 'does not accept non-json inputs' do
    get '/', 'плптье женская'
    expect(last_response.status).to eq(400)
    expect(json_response['error']).to be_truthy
  end
end
