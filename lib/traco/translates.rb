module Traco
  module Translates
    def translates(*columns)
      set_up_once
      store_as_translatable_columns columns.map(&:to_sym)
    end

    private

    # Don't overwrite values if running multiple times in the same
    # class or in different classes of an inheritance chain.
    def set_up_once
      return if respond_to?(:translatable_columns)

      extend Traco::ClassMethods

      class_attribute :translatable_columns
      self.translatable_columns = []
    end

    def store_as_translatable_columns(columns)
      self.translatable_columns |= columns

      columns.each do |column|
        define_localized_reader column
        define_localized_writer column
      end
    end

    def define_localized_reader(column)
      define_method(column) do
        @localized_readers ||= {}
        @localized_readers[column] ||= Traco::LocalizedReader.new(self, column)
        @localized_readers[column].value
      end
    end

    def define_localized_writer(column)
      define_method("#{column}=") do |value|
        send("#{column}_#{I18n.locale}=", value)
      end
    end
  end
end

ActiveRecord::Base.send :extend, Traco::Translates
