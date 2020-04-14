require "traco/locale_fallbacks"

RSpec.describe Traco::LocaleFallbacks do
  describe ".new" do
    it "raises ArgumentError if an unknown argument passed in" do
      expect { Traco::LocaleFallbacks.new(:foo) }.to raise_error(ArgumentError)
      expect { Traco::LocaleFallbacks.new(nil) }.to raise_error(ArgumentError)
    end
  end

  describe "#[]" do
    context "with the ':default' option" do
      it "returns given locale, then default locale" do
        I18n.default_locale = :en
        subject = Traco::LocaleFallbacks.new(:default)
        expect(subject[:sv]).to eq [ :sv, :en ]
      end
    end

    context "with the ':any' option" do
      it "returns given locale, then default locale, then remaining available locales alphabetically" do
        I18n.default_locale = :en
        I18n.available_locales = [ :en, :sv, :uk, :de ]

        subject = Traco::LocaleFallbacks.new(:any)
        expect(subject[:sv]).to eq [ :sv, :en, :de, :uk ]
      end
    end

    context "with the 'false' option" do
      it "returns only given locale" do
        subject = Traco::LocaleFallbacks.new(false)
        expect(subject[:sv]).to eq [ :sv ]
      end
    end

    context "with an explicit list of locales" do
      it "returns only those locales, after the current one" do
        subject = Traco::LocaleFallbacks.new([ :en ])
        expect(subject[:sv]).to eq [ :sv, :en ]
      end
    end

    context "with the ':default_first' option" do
      it "returns default locale, then remaining available locales alphabetically" do
        I18n.default_locale = :uk
        I18n.available_locales = [ :en, :sv, :uk, :de ]

        subject = Traco::LocaleFallbacks.new(:default_first)
        expect(subject[:sv]).to eq [ :uk, :de, :en, :sv ]
      end
    end

    context "with the ':i18n' option" do
      it "returns what is configured as a I18n fallback" do
        I18n.fallbacks = I18n::Locale::Fallbacks.new(
          en: [ :en, :uk, :de, :sv ],
          uk: [ :uk, :en, :de, :sv ],
          de: [ :de, :uk, :en, :sv ],
          sv: [ :sv, :en, :uk, :de ],
        )

        subject = Traco::LocaleFallbacks.new(:i18n)
        expect(subject[:sv]).to eq [ :sv, :en, :uk, :de ]
        expect(subject[:de]).to eq [ :de, :uk, :en, :sv ]
      end
    end
  end
end
