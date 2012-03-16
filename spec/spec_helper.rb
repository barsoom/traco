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

spec_dir = File.dirname(__FILE__)

require "active_record"
databases = YAML.load File.read("#{spec_dir}/app/database.yml")
ActiveRecord::Base.establish_connection databases["test"]
require "#{spec_dir}/app/schema.rb"

require "app/post"

I18n.load_path << "#{spec_dir}/app/sv.yml"
