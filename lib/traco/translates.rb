module Traco
  module Translates
    def translates(*columns)
    end
  end
end

ActiveRecord::Base.send :extend, Traco::Translates
