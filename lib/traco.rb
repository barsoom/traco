require "traco/version"
require "traco/attributes"
require "traco/locale_fallbacks"
require "traco/translates"

module Traco
  COLUMN_RE =
    /\A
      (?<attribute>\w+?)        # title
      _                         # _
      (?<primary>[a-z]{2})      # pt
      (
        _                       # _
        (?<extended>[a-z]{2})   # br
      )?
    \z/x

  # @example
  #   Traco.column("title", :sv)      # => :title_sv
  #   Traco.column("title", :"pt-BR") # => :title_pt_br
  def self.column(attribute, locale)
    normalized_locale = locale.to_s.downcase.sub("-", "_")
    "#{attribute}_#{normalized_locale}".to_sym
  end

  # @example
  #   Traco.split_localized_column("title_sv")     # => [:title, :sv]
  #   Traco.split_localized_column("title_pt_br")  # => [:title, :"pt-BR"]
  #   Traco.split_localized_column("unlocalized")  # => nil
  def self.split_localized_column(column)
    if (md = column.to_s.match(COLUMN_RE))
      attribute = md[:attribute]

      primary_locale = md[:primary]
      locale =
        if (extended_locale = md[:extended])
          "#{primary_locale}-#{extended_locale.upcase}"
        else
          primary_locale
        end

      [attribute.to_sym, locale.to_sym]
    end
  end

  def self.locale_name(locale)
    default = locale.to_s.upcase.sub("_", "-")
    I18n.t(locale, scope: :"i18n.languages", default: default)
  end

  def self.locale_with_fallbacks(locale, fallback_option)
    locale_fallbacks_resolver = LocaleFallbacks.new(fallback_option)
    locale_fallbacks_resolver[locale]
  end
end
