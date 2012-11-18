module Traco
  class LocalizedReader
    def initialize(record, column)
      @record = record
      @column = column
    end

    def value
      locales.each do |locale|
        value = @record.send("#{@column}_#{locale}")
        return value if value.present?
      end

      nil
    end

    private

    def locales
      @record.class.locales_for_column(@column).sort_by { |locale|
        locale_sort_value(locale)
      }
    end

    def locale_sort_value(locale)
      case locale
      when I18n.locale
        # Sort the current locale first.
        "0"
      when I18n.default_locale
        # Sort the default locale second.
        "1"
      else
        # Sort the rest alphabetically.
        locale.to_s
      end
    end
  end
end
