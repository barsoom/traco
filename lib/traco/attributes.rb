module Traco
  class Attributes < Module
    def initialize(*attributes)
      @options = attributes.extract_options!
      @attributes = attributes.map(&:to_sym)

      attributes.each do |attribute|
        define_reader(attribute)
        define_writer(attribute)
      end
    end

    def included(base)
      self.class.ensure_translatable_attributes(base)
      base.translatable_attributes |= @attributes

      self.class.warm_up_activerecord_methods(base)

      base.extend ClassMethods
    end

    private

    def define_reader(attribute)
      class_eval <<-EOM, __FILE__, __LINE__ + 1
        def #{attribute}(options = {})
          default_fallback = #{@options.fetch(:fallback, LocaleFallbacks::DEFAULT_FALLBACK).inspect}
          fallback = options.fetch(:fallback, default_fallback)
          columns_to_try = self.class.locale_columns_for_attribute(:#{attribute}, fallback)
          columns_to_try.each do |column|
            value = send(column)
            return value if value.present?
          end

          nil
        end
      EOM
    end

    def define_writer(attribute)
      class_eval <<-EOM, __FILE__, __LINE__ + 1
        def #{attribute}=(value)
          column = Traco.column(:#{attribute}, I18n.locale).to_s << "="
          send(column, value)
        end
      EOM
    end

    # Only called once per class or inheritance chain (e.g. once
    # for the superclass, not at all for subclasses). The separation
    # is important if we don't want to overwrite values if running
    # multiple times in the same class or in different classes of
    # an inheritance chain.
    def self.ensure_translatable_attributes(base)
      return if base.respond_to?(:translatable_attributes)
      base.class_attribute :translatable_attributes
      base.translatable_attributes = []
    end

    # Force AR to create methods `title_en` etc, which are lazily evaluated,
    # otherwise we can't safely check `.instance_methods`.
    def self.warm_up_activerecord_methods(base)
      random_attribute = base.translatable_attributes.first

      instance = base.new
      instance.send(Traco.column(random_attribute, I18n.default_locale))
    end
  end
end

require "traco/attributes/class_methods"
