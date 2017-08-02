# frozen_string_literal: true

require_relative '../lib/spellchecker'

RSpec.describe Spellchecker do
  subject do
    custom_dic_path = File.join File.dirname(__FILE__), 'fixtures', 'custom.dic'
    described_class.new(custom_dictionary: custom_dic_path)
  end

  it 'replaces incorrect words' do
    expect(subject.call('плптье женская')).to eq('платье женская')
  end

  it "doesn't replace words in custom dictionary" do
    expect(subject.call('айфон 7')).to eq('айфон 7')
  end

  it "doesn't replace known words" do
    expect(subject.call('джинсы дёшево')).to eq('джинсы дёшево')
  end

  it "doesn't replace unknown words without suggestions" do
    expect(subject.call('йцукенгшщзх')).to eq('йцукенгшщзх')
  end
end
