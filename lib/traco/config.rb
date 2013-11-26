require 'active_support/configurable'

module Traco
  # Configures global settings for Kaminari
  #   Traco.configure do |config|
  #     config.something = 'some_value'
  #   end
  def self.configure(&block)
    yield config
  end

  # Global settings for Traco
  def self.config
    @config ||= Traco::Configuration.new
  end

  class Configuration #:nodoc:
    include ActiveSupport::Configurable

    config_accessor :attribute_name_format
  end

  # Set default values if you want to
  # configure do |config|
    # config.attribute_name_format = :unmodified
    # config.attribute_name_format = :ruby
  # end
end
