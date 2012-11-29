module Traco
  class LocalizedReader
    def initialize(record, column)
      @record = record
      @column = column
    end

    def value
      locales_to_try.each do |locale|
        value = @record.send("#{@column}_#{locale}")
        return value if value.present?
      end

      nil
    end

    private

    def locales_to_try
      @locales_to_try ||= [I18n.locale, I18n.default_locale] & locales_for_column
    end

    def locales_for_column
      @record.class.locales_for_column(@column)
    end
  end
end
