module Traco
  module InstanceMethods

    private

    def read_localized_value(column)      
      locales_for_reading_column(column, self.traco_fallback_method).each do |locale|
        value = send("#{column}_#{locale}")
        return value if value.present?
      end
      nil
    end

    def write_localized_value(column, value)
      send("#{column}_#{I18n.locale}=", value)
    end

    def locales_for_reading_column(column, fallback_method)
      locales = sorted_locales_for_column(column) 
      if fallback_method == false
        return [I18n.locale]
      elsif fallback_method == :default_locale
        return locales.select { |l| l == I18n.locale || l == I18n.default_locale }
      else
        return locales
      end
    end
    
    def sorted_locales_for_column(column)
      self.class.locales_for_column(column).sort_by { |locale|
        case locale
        when I18n.locale then "0"
        when I18n.default_locale then "1"
        else locale.to_s
        end
      }
    end
  end
end
