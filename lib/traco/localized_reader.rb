module Traco
  class LocalizedReader
    def initialize(record, attribute, options)
      @record = record
      @attribute = attribute
      @fallback = options[:fallback]
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
      chain << I18n.default_locale    if @fallback
      chain += I18n.available_locales if @fallback == :any
      chain.map { |locale| Traco.locale_suffix(locale) }
    end

    def locales_for_attribute
      @record.class.locales_for_attribute(@attribute)
    end
  end
end
