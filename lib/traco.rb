require "traco/version"
require "traco/translates"
require "traco/class_methods"
require "traco/localized_reader"

module Traco
  # E.g. :sv -> :sv, :"pt-BR" -> :pt_br
  def self.locale_suffix(locale = I18n.locale)
    locale.to_s.downcase.sub("-", "_").to_sym
  end
end
