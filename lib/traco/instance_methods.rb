module Traco
  module InstanceMethods

    private

    def read_localized_value(column)
      locales_for_reading_column(column).each do |locale|
        value = public_send("#{column}_#{locale}")
        value = public_send("#{column}_#{locale}")
        return value if value.present?
      end
      nil
    end

    def write_localized_value(column, value)
      public_send("#{column}_#{I18n.locale}=", value)
    end

    def locales_for_reading_column(column)
      self.class.locales_for_column(column).sort_by { |x|
        case x
        when I18n.locale then :"0"
        when I18n.default_locale then :"1"
        else x
        end
      }
    end

  end
end
