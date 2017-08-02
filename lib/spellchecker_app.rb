# frozen_string_literal: true

require 'bundler'
Bundler.require

require_relative 'spellchecker'

# Spellchecker applicatio
class SpellcheckerApp
  def initialize
    @custom_dictionary = ENV.fetch('DICTIONARY_FILE') do
      File.expand_path('custom.dic')
    end
  end

  def call(environment)
    request = Rack::Request.new(environment)
    return error('Non-POST request') unless request.post?
    data = JSON.parse(request.body.read)
    return error('Empty query parameter') unless data['query']
    corrected_query = spellchecker.call(data['query'])
    respond(result: corrected_query)
  rescue JSON::ParserError => e
    error("Invalid JSON: #{e.message}")
  end

  private

  def spellchecker
    Thread.current[:spellchecker] ||=
      Spellchecker.new(custom_dictionary: @custom_dictionary)
  end

  def respond(response, code: :ok)
    code = Rack::Utils::SYMBOL_TO_STATUS_CODE[code] || code
    [code, { 'Content-Type' => 'application/json' }, [JSON.dump(response)]]
  end

  def error(message, code: :bad_request)
    respond({ error: message }, code: code)
  end
end
