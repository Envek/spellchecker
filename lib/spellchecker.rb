# frozen_string_literal: true

require 'ffi/hunspell'

# Provides spelling corrections via Hunspell shared library
class Spellchecker
  # @param custom_dictionary [String] Full path to custom additional dictionary.
  #   It must be compatible by affixes and encoding with main ru_RU dictionary.
  def initialize(custom_dictionary: nil)
    @dict = FFI::Hunspell.dict('ru_RU')
    return unless custom_dictionary
    @dict.add_dic(custom_dictionary)
    ObjectSpace.define_finalizer(self, proc { @dict.close })
  end

  # @param query [String] A string to check and correct
  # @return [String] Input string with corrected words
  def call(query)
    query.split.map { |word| correct(word) }.join(' ')
  end

  private

  def correct(word)
    encoded_word = word.encode(@dict.encoding, invalid: :replace, undef: :replace, replace: '')
    return word if @dict.check?(encoded_word)
    @dict.suggest(encoded_word).first&.encode(__ENCODING__) || word
  end
end
