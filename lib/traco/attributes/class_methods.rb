module Traco
  class Attributes
    module ClassMethods
      def locales_for_attribute(attribute, fallback = LocaleFallbacks::ANY_FALLBACK)
        _traco_cache(attribute, fallback).keys
      end

      def locale_columns_for_attribute(attribute, fallback = LocaleFallbacks::ANY_FALLBACK)
        _traco_cache(attribute, fallback).values
      end

      def locale_columns(*attributes)
        attributes.each_with_object([]) do |attribute, columns|
          columns.concat(locale_columns_for_attribute(attribute))
        end
      end

      def current_locale_column(attribute)
        Traco.column(attribute, I18n.locale)
      end

      def human_attribute_name(column, options = {})
        attribute, locale = Traco.split_localized_column(column)
        if translates?(attribute)
          default = super(column, options.merge(default: ""))
          default.presence || "#{super(attribute, options)} (#{Traco.locale_name(locale)})"
        else
          super
        end
      end

      private

      def translates?(attribute)
        translatable_attributes.include?(attribute)
      end

      # Structured by (current) locale => attribute => fallback option => {locale_to_try => column}.
      # @example
      #     {:"pt-BR" => {
      #       title: {
      #         default: {:"pt-BR" => :title_pt_br, :en => :title_en},
      #         any: {:"pt-BR" => :title_pt_br, :en => :title_en, :sv => :title_sv},
      #       },
      #     :sv => {
      #       title: {
      #         default: {:sv => :title_sv, :en => :title_en},
      #         any: {:sv => :title_sv, :en => :title_en, :"pt-BR" => :title_pt_br}
      #       }
      #     }}
      def _traco_cache(attribute, fallback)
        cache = @_traco_cache ||= {}
        per_locale_cache = cache[I18n.locale] ||= {}
        per_attribute_cache = per_locale_cache[attribute] ||= {}
        per_attribute_cache[fallback] ||=
          begin
            locales_to_try = Traco.locale_with_fallbacks(I18n.locale, fallback)
            locales_to_try.each_with_object({}) do |locale, columns|
              column = Traco.column(attribute, locale)
              columns[locale] = column if instance_methods.include?(column)
            end
          end
      end
    end
  end
end
