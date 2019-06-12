# Intended to be API compatible with https://github.com/svenfuchs/i18n/blob/master/lib/i18n/locale/fallbacks.rb

module Traco
  class LocaleFallbacks
    OPTIONS = [
      DEFAULT_FALLBACK = :default,
      ANY_FALLBACK = :any,
      NO_FALLBACK = false,
      DEFAULT_FIRST_FALLBACK = :default_first,
      I18N_FALLBACK = :i18n,
    ]

    attr_reader :fallback_option
    private :fallback_option

    def initialize(fallback_option)
      validate_option(fallback_option)

      @fallback_option = fallback_option
      @default_locale = I18n.default_locale
      @available_locales = I18n.available_locales.sort
    end

    def [](current_locale)
      case fallback_option
      when DEFAULT_FALLBACK       then [ current_locale, @default_locale ]
      when ANY_FALLBACK           then [ current_locale, @default_locale, *@available_locales ].uniq
      when NO_FALLBACK            then [ current_locale ]
      when DEFAULT_FIRST_FALLBACK then [ @default_locale, *@available_locales ].uniq
      when I18N_FALLBACK          then I18n.fallbacks[current_locale]
      when Array                  then [ current_locale, *fallback_option ]
      else                        raise "Unknown fallback."  # Should never get here.
      end
    end

    private

    def validate_option(fallback_option)
      return if OPTIONS.include?(fallback_option)
      return if fallback_option.is_a?(Array)

      valids = OPTIONS.map(&:inspect).join(", ")
      raise ArgumentError.new("Unsupported fallback: #{fallback_option.inspect} (expected one of #{valids}, or an array)")
    end
  end
end
