module Traco
  module InstanceMethods

    private

    def read_localized_value(column)
      locales_for_reading_column(column).each do |locale|
        value = send("#{column}_#{locale}")
        return value if value.present?
      end
      nil
    end

    def write_localized_value(column, value)
      send("#{column}_#{I18n.locale}=", value)
    end

    def locales_for_reading_column(column)
      self.class.locales_for_column(column).sort_by { |locale|
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
