module Traco
  module ClassMethods

    def locales_for_column(column)
      column_names.grep(/\A#{column}_([a-z]{2})\z/) {
        $1.to_sym
      }.sort_by { |x|
        x == I18n.default_locale ? :"" : x
      }
    end

    def human_attribute_name(attribute, options={})
      default = super(attribute, { default: "" }.merge(options))
      if !default.present? && attribute.to_s.match(/\A(\w+)_([a-z]{2})\z/)
        column, locale = $1, $2.to_sym
        if translates?(column)
          locale_name = I18n.t(locale, scope: :"i18n.languages", default: locale.to_s.upcase)
          return "#{super(column, options)} (#{locale_name})"
        end
      end
      super
    end

    private

    def translates?(column)
      @translates_columns.include?(column.to_sym)
    end

  end
end
