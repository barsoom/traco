module Traco
  module LocaleRegularExpressions
    SNAKE_CASE = /[a-zA-Z]{2}(?:_[a-zA-Z]{2})?/
  end

  # Generates the column name from attribute_name (e.g. `title`) and locale (e.g. `en`)
  # Example: The format is :ruby, :title & :"pt-BR" => :title_pt_br
  def self.attribute_name_with_locale(attribute_name, locale)
    locale = locale.to_s.gsub(/-/, '_').downcase
    "#{attribute_name}_#{locale}"
  end

  # Convert locale name extracted from column name back to normal locale
  # Example: The format is :ruby, :pt_br => :"pt-BR"
  def self.locale_from_column_name_part(locale_from_column_name)
    locale = locale_from_column_name.to_s.split('_').each_with_index.map do |locale_part, index|
      index == 0 ? locale_part : locale_part.upcase
    end.join('-')
    locale.to_sym
  end

  module ClassMethods
    def locales_for_attribute(attribute)
      re = /\A#{attribute}_(#{locale_regular_expression_for_attribute_name})\z/

      column_names.
        grep(re) { Traco.locale_from_column_name_part($1) }.
        sort_by(&locale_sort_value)
    end

    def locale_columns(*attributes)
      attributes.inject([]) { |memo, attribute|
        memo += locales_for_attribute(attribute).map { |locale|
          Traco.attribute_name_with_locale(attribute, locale).to_sym
        }
      }
    end

    def human_attribute_name(full_attribute_name, options = {})
      default = super(full_attribute_name, options.merge(:default => ""))
      if default.blank? && full_attribute_name.to_s.match(/\A(\w+)_(#{locale_regular_expression_for_attribute_name})\z/)
        column, locale = $1, $2.to_sym
        if translates?(column)
          return "#{super(column, options)} (#{locale_name(locale)})"
        end
      end
      super
    end

    private

    def locale_sort_value
      lambda { |locale|
        if locale == I18n.default_locale
          # Sort the default locale first.
          "0"
        else
          # Sort the rest alphabetically.
          locale.to_s
        end
      }
    end

    def translates?(attribute)
      translatable_attributes.include?(attribute.to_sym)
    end

    def locale_name(locale)
      locale = Traco.locale_from_column_name_part(locale)
      I18n.t(locale, :scope => :"i18n.languages", :default => locale.to_s.upcase)
    end

    def locale_regular_expression_for_attribute_name
      Traco::LocaleRegularExpressions::SNAKE_CASE
    end
  end
end
