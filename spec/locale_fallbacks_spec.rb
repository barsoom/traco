require "i18n"
require "traco/locale_fallbacks"

describe Traco::LocaleFallbacks do
  describe "#initialize" do
    it "accepts :default, :any, and false as valid arguments" do
      expect {
        Traco::LocaleFallbacks.new(:default)
        Traco::LocaleFallbacks.new(:any)
        Traco::LocaleFallbacks.new(false)
      }.not_to raise_error
    end

    it "raises ArgumentError if invalid argument passed in" do
      expect { Traco::LocaleFallbacks.new(:invalid) }.to raise_error(ArgumentError)
      expect { Traco::LocaleFallbacks.new(nil) }.to raise_error(ArgumentError)
    end
  end

  describe "#[]" do
    context "with the :default option" do
      it "returns locale, then default locale" do
        I18n.default_locale = :en
        subject = Traco::LocaleFallbacks.new(:default)
        expect(subject[:sv]).to eq [ :sv, :en ]
      end
    end

    context "with the :any option" do
      it "returns locale, then default locale, then available locales alphabetically sorted" do
        I18n.default_locale = :en
        I18n.available_locales = [ :en, :sv, :uk, :de ]
        subject = Traco::LocaleFallbacks.new(:any)
        expect(subject[:sv]).to eq [ :sv, :en, :de, :uk ]
      end
    end

    context "with the false option" do
      it "returns only locale" do
        subject = Traco::LocaleFallbacks.new(false)
        expect(subject[:sv]).to eq [ :sv ]
      end
    end
  end
end
