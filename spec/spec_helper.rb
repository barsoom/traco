RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # Clear class state before each spec.
  config.before(:each) do
    Object.send(:remove_const, 'Post')
    load 'app/post.rb'
  end

end

# Test against real ActiveRecord models.
# Very much based on the test setup in
# https://github.com/iain/translatable_columns/

require "active_record"
require "app/post.rb"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: "spec/app/test.sqlite3"
require_relative "app/schema.rb"

I18n.load_path << "spec/app/sv.yml"
