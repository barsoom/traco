module Traco
  module InstanceMethods

    private

    def read_localized_value(column)
      locales_for_reading_column(column).each do |locale|
        value = public_send("#{column}_#{locale}")
        return value if value.present?
      end
      nil
    end

    def write_localized_value(column, value)
      public_send("#{column}_#{I18n.locale}=", value)
    end

    def locales_for_reading_column(column)
      self.class.locales_for_column(column).sort_by { |locale|
        case locale
        when I18n.locale then "0"
        when I18n.default_locale then "1"
        else locale.to_s
        end
      }.map { |x|
        x.to_sym
      }
    end

    # To make Ruby 1.8.7 compatible
    # From https://github.com/marcandre/backports/blob/master/lib/backports/1.9.1/kernel.rb
    # Standard in ruby 1.9. See official documentation[http://ruby-doc.org/core-1.9/classes/Object.html]
    def public_send(method, *args, &block)
      if respond_to?(method) && !protected_methods.include?(method.to_s)
        send(method, *args, &block)
      else
        :foo.generate_a_no_method_error_in_preparation_for_method_missing rescue nil
        # otherwise a NameError might be raised when we call method_missing ourselves
        method_missing(method.to_sym, *args, &block)
      end
    end unless method_defined? :public_send


  end
end
