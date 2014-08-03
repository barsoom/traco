require "i18n"
require "traco/locale_fallbacks"

describe Traco::LocaleFallbacks do
  describe "#initialize" do
    it "accepts :default, :any, nil and false as valid arguments" do
      described_class.new(:default)
      described_class.new(:any)
      described_class.new(false)
    end

    it "raises ArgumentError if invalid argument passed in" do
      expect{ described_class.new(:invalid) }.to raise_error(ArgumentError)
    end
  end

  describe "#[]" do
    it "returns locale, then default locale for :default option" do
      expect(I18n).to receive(:default_locale).and_return(:en)
      subject = described_class.new(:default)
      expect(subject[:sv]).to eq [:sv, :en]
    end

    it "returns locale, then default locale, then available locales alphabetically sorted for :any option" do
      expect(I18n).to receive(:default_locale).and_return(:en)
      expect(I18n).to receive(:available_locales).and_return([:en, :sv, :uk, :de])
      subject = described_class.new(:any)
      expect(subject[:sv]).to eq [:sv, :en, :de, :uk]
    end

    it "returns only locale for 'false' option" do
      subject = described_class.new(false)
      expect(subject[:sv]).to eq [:sv]
    end
  end
end
