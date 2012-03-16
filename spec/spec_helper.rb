RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # Clear class state before each spec.
  config.before(:each) do
    Object.send(:remove_const, 'Post')
    load 'dummy/app/models/post.rb'
  end

end

# Rails

ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!
