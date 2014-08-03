module Traco
  class LocaleFallbacks
    OPTIONS = [
      DEFAULT_FALLBACK = :default,
      ANY_FALLBACK = :any,
      NO_FALLBACK = false,
    ]

    ArgumentError = Class.new(::ArgumentError)

    attr_reader :fallback_option

    def initialize(fallback_option)
      @fallback_option = validate_option!(fallback_option)
      @default_locale = I18n.default_locale
      @available_locales = I18n.available_locales.sort
    end

    def [](for_locale)
      chain = [for_locale]
      chain << @default_locale if include_default_locale?
      chain |= @available_locales if include_available_locales?
      chain
    end

    private

    def include_default_locale?
      [DEFAULT_FALLBACK, ANY_FALLBACK].include?(fallback_option)
    end

    def include_available_locales?
      ANY_FALLBACK == fallback_option
    end

    def validate_option!(fallback_option)
      unless OPTIONS.include?(fallback_option)
        valids = OPTIONS.map(&:inspect).join(", ")
        raise ArgumentError.new("Unsupported fallback: #{fallback_option.inspect} (expected one of #{valids})")
      end
      fallback_option
    end
  end
end
