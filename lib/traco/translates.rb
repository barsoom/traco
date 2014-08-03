module Traco
  module Translates
    def translates(*attributes)
      include Traco::Attributes.new(*attributes)
    end
  end
end

ActiveRecord::Base.send :extend, Traco::Translates
