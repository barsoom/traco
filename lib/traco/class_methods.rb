module Traco
  module ClassMethods
    LOCALE_RE = /[a-zA-Z]{2}(?:_[a-zA-Z]{2})?/

    def locales_for_attribute(attribute)
      re = /\A#{attribute}_(#{LOCALE_RE})\z/

      column_names.
        grep(re) { $1.to_sym }.
        sort_by(&locale_sort_value)
    end

    def locale_columns(*attributes)
      attributes.inject([]) { |memo, attribute|
        memo += locales_for_attribute(attribute).map { |locale|
          :"#{attribute}_#{locale}"
        }
      }
    end

    def human_attribute_name(attribute, options = {})
      default = super(attribute, options.merge(default: ""))

      if default.blank? && attribute.to_s.match(/\A(\w+?)_(#{LOCALE_RE})\z/)
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
        if locale == Traco.locale_suffix(I18n.default_locale)
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
      default = locale.to_s.upcase.sub("_", "-")
      I18n.t(locale, scope: :"i18n.languages", default: default)
    end
  end
end
