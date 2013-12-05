module Traco
  class AttributeSetup
    INSTANCE_METHODS_MODULE_NAME = "TracoInstanceMethods"

    def initialize(klass)
      @klass = klass
    end

    def set_up(attributes, options)
      ensure_class_methods
      ensure_attribute_list
      ensure_instance_methods_module
      add_attributes attributes, options
    end

    private

    def ensure_class_methods
      klass.extend Traco::ClassMethods
    end

    # Only called once per class or inheritance chain (e.g. once
    # for the superclass, not at all for subclasses). The separation
    # is important if we don't want to overwrite values if running
    # multiple times in the same class or in different classes of
    # an inheritance chain.
    def ensure_attribute_list
      return if klass.respond_to?(:translatable_attributes)
      klass.class_attribute :translatable_attributes
      klass.translatable_attributes = []
    end

    def ensure_instance_methods_module
      # Instance methods are defined on an included module, so your class
      # can just redefine them and call `super`, if you need to.
      # http://thepugautomatic.com/2013/07/dsom/
      unless klass.const_defined?(INSTANCE_METHODS_MODULE_NAME, _search_ancestors = false)
        klass.send :include, klass.const_set(INSTANCE_METHODS_MODULE_NAME, Module.new)
      end
    end

    def add_attributes(attributes, options)
      klass.translatable_attributes |= attributes

      attributes.each do |attribute|
        define_localized_reader attribute, options
        define_localized_writer attribute, options
      end
    end

    def define_localized_reader(attribute, options)
      fallback = options.fetch(:fallback, true)

      custom_define_method(attribute) do
        @localized_readers ||= {}
        @localized_readers[attribute] ||= Traco::LocalizedReader.new(self, attribute, fallback: fallback)
        @localized_readers[attribute].value
      end
    end

    def define_localized_writer(attribute, options)
      custom_define_method("#{attribute}=") do |value|
        suffix = Traco.locale_suffix(I18n.locale)
        send("#{attribute}_#{suffix}=", value)
      end
    end

    def custom_define_method(name, &block)
      klass.const_get(INSTANCE_METHODS_MODULE_NAME).module_eval do
        define_method(name, &block)
      end
    end

    def klass
      @klass
    end
  end
end
