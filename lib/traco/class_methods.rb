module Traco
  module ClassMethods
    def locales_for_attribute(attribute)
      traco_cache(attribute, LocaleFallbacks::DEFAULT_FIRST_FALLBACK).keys
    end

    def locale_columns(*attributes)
      attributes.each_with_object([]) do |attribute, columns|
        columns.concat(_locale_columns_for_attribute(attribute, LocaleFallbacks::DEFAULT_FIRST_FALLBACK))
      end
    end

    # Consider this method internal.
    def _locale_columns_for_attribute(attribute, fallback)
      traco_cache(attribute, fallback).values
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
    #     {
    #       :"pt-BR" => {
    #         title: {
    #           default: { :"pt-BR" => :title_pt_br, :en => :title_en },
    #           any: { :"pt-BR" => :title_pt_br, :en => :title_en, :sv => :title_sv }
    #         },
    #       },
    #       :sv => {
    #         title: {
    #           default: { :sv => :title_sv, :en => :title_en },
    #           any: { :sv => :title_sv, :en => :title_en, :"pt-BR" => :title_pt_br }
    #         }
    #       }
    #     }
    def traco_cache(attribute, fallback)
      cache = @traco_cache ||= {}
      per_locale_cache = cache[I18n.locale] ||= {}
      per_attribute_cache = per_locale_cache[attribute] ||= {}

      per_attribute_cache[fallback] ||= begin
        # AR methods are lazily evaluated, so we should use `respond_to?` on this
        # class instance, rather then `instance_methods.include?(:title_en)`
        instance = new

        locales_to_try = Traco.locale_with_fallbacks(I18n.locale, fallback)

        locales_to_try.each_with_object({}) do |locale, columns|
          column = Traco.column(attribute, locale)
          columns[locale] = column if instance.respond_to?(column)
        end
      end
    end
  end
end
