require "traco/attribute_setup"

module Traco
  module Translates
    def translates(*attributes)
      options = attributes.extract_options!
      attributes = attributes.map(&:to_sym)
      AttributeSetup.new(self).set_up(attributes, options)
    end
  end
end

ActiveRecord::Base.send :extend, Traco::Translates
