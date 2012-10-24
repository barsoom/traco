module Traco
  module Translates
    def translates(*columns)

      extend Traco::ClassMethods
      include Traco::InstanceMethods

      # Don't overwrite values if running multiple times in the same class
      # or in different classes of an inheritance chain.
      unless respond_to?(:translatable_columns)
        class_attribute :translatable_columns
        self.translatable_columns = []
      end
      
      # Set fallback method. If no fallback option is given, 
      # set to default "true" (always fallback)
      options = columns.extract_options!
      class_attribute :traco_fallback_method
      self.traco_fallback_method = options[:fallback]

      self.translatable_columns |= columns.map(&:to_sym)

      columns.each do |column|

        define_method(column) do
          read_localized_value(column)
        end

        define_method("#{column}=") do |value|
          write_localized_value(column, value)
        end

      end
    end
  end
end

ActiveRecord::Base.send :extend, Traco::Translates
