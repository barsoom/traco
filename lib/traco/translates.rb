module Traco
  module Translates
    def translates(*columns)
      options = columns.extract_options!
      set_up_once
      store_as_translatable_columns columns.map(&:to_sym), options
    end

    private

    # Don't overwrite values if running multiple times in the same
    # class or in different classes of an inheritance chain.
    def set_up_once
      return if respond_to?(:translatable_columns)

      class_attribute :traco_instance_methods

      class_attribute :translatable_columns
      self.translatable_columns = []

      extend Traco::ClassMethods
    end

    def store_as_translatable_columns(columns, options)
      fallback = options.fetch(:fallback, true)

      self.translatable_columns |= columns

      # Instance methods are defined on an included module, so your class
      # can just redefine them and call `super`, if you need to.
      self.traco_instance_methods = Module.new
      include traco_instance_methods

      columns.each do |column|
        define_localized_reader column, :fallback => fallback
        define_localized_writer column
      end
    end

    def define_localized_reader(column, options)
      fallback = options[:fallback]

      traco_instance_methods.module_eval do
        define_method(column) do
          @localized_readers ||= {}
          @localized_readers[column] ||= Traco::LocalizedReader.new(
            self,
            column,
            :fallback => fallback
          )
          @localized_readers[column].value
        end
      end
    end

    def define_localized_writer(column)
      traco_instance_methods.module_eval do
        define_method("#{column}=") do |value|
          send("#{column}_#{I18n.locale}=", value)
        end
      end
    end
  end
end

ActiveRecord::Base.send :extend, Traco::Translates
