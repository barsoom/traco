module Traco
  module ClassMethods

    def translatable_columns
      @translatable_columns
    end

    def locales_for_column(column)
      column_names.grep(/\A#{column}_([a-z]{2})\z/) {
        $1
      }.sort_by { |locale| 
        if locale == I18n.default_locale
          "aa"
        else
          locale.to_s
        end
      }.map { |x|
        x.to_sym
      }      
    end

    def human_attribute_name(attribute, options={})
      default = super(attribute, options.merge(:default => ""))
      if default.blank? && attribute.to_s.match(/\A(\w+)_([a-z]{2})\z/)
        column, locale = $1, $2.to_sym
        if translates?(column)
          return "#{super(column, options)} (#{locale_name(locale)})"
        end
      end
      super
    end

    private

    def translates?(column)
      translatable_columns.include?(column.to_sym)
    end

    def locale_name(locale)
      I18n.t(locale, :scope => :"i18n.languages", :default => locale.to_s.upcase)
    end

  end
end
