module Traco
  class LocalizedReader
    FALLBACK_OPTIONS = [
      DEFAULT_FALLBACK = :default,
      ANY_FALLBACK = :any,
      NO_FALLBACK = false,
    ]

    def initialize(record, attribute, options)
      @record = record
      @attribute = attribute
      @fallback = options[:fallback]
      validate_fallback
    end

    def value
      locales_to_try.each do |locale|
        value = @record.send("#{@attribute}_#{Traco.locale_suffix(locale)}")
        return value if value.present?
      end

      nil
    end

    private

    def locales_to_try
      locale_chain & locales_for_attribute
    end

    def locale_chain
      chain = []
      chain << I18n.locale
      chain << I18n.default_locale    if [DEFAULT_FALLBACK, ANY_FALLBACK].include?(@fallback)
      chain += I18n.available_locales if @fallback == ANY_FALLBACK
      chain.map { |locale| Traco.locale_suffix(locale) }
    end

    def locales_for_attribute
      @record.class.locales_for_attribute(@attribute)
    end

    def validate_fallback
      unless FALLBACK_OPTIONS.include?(@fallback)
        valids = FALLBACK_OPTIONS.map(&:inspect).join(", ")
        raise "Unsupported fallback: #{@fallback.inspect} (expected one of #{valids})"
      end
    end
  end
end
