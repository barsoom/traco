module Traco
  module Translates
    def translates(*attributes)
      options = attributes.extract_options!
      set_up_once
      store_as_translatable_attributes attributes.map(&:to_sym), options
    end

    private

    # Only called once per class or inheritance chain (e.g. once
    # for the superclass, not at all for subclasses). The separation
    # is important if we don't want to overwrite values if running
    # multiple times in the same class or in different classes of
    # an inheritance chain.
    def set_up_once
      return if respond_to?(:translatable_attributes)

      class_attribute :translatable_attributes

      self.translatable_attributes = []
      extend Traco::ClassMethods
    end

    def store_as_translatable_attributes(attributes, options)
      fallback = options.fetch(:fallback, true)

      self.translatable_attributes |= attributes

      # Instance methods are defined on an included module, so your class
      # can just redefine them and call `super`, if you need to.
      unless @traco_instance_methods
        @traco_instance_methods = Module.new
        include @traco_instance_methods
      end

      attributes.each do |attribute|
        define_localized_reader attribute, :fallback => fallback
        define_localized_writer attribute
      end
    end

    def define_localized_reader(attribute, options)
      fallback = options[:fallback]

      @traco_instance_methods.module_eval do
        define_method(attribute) do
          @localized_readers ||= {}
          @localized_readers[attribute] ||= Traco::LocalizedReader.new(self, attribute, :fallback => fallback)
          @localized_readers[attribute].value
        end
      end
    end

    def define_localized_writer(attribute)
      @traco_instance_methods.module_eval do
        define_method("#{attribute}=") do |value|
          send("#{attribute}_#{I18n.locale}=", value)
        end
      end
    end
  end
end

ActiveRecord::Base.send :extend, Traco::Translates
