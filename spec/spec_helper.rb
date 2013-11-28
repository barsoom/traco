RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # Clear class state before each spec.
  config.before(:each) do
    Object.send(:remove_const, 'Post')
    Object.send(:remove_const, 'SubPost')
    load 'app/post.rb'
  end
end

# Test against real ActiveRecord models.
# Very much based on the test setup in
# https://github.com/iain/translatable_columns/

require "active_record"
require "app/post.rb"

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

silence_stream(STDOUT) do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :posts, :force => true do |t|
      t.string :title_sv, :title_en, :title_fi, :title_pt_br
      t.string :body_sv, :body_en, :body_fi, :body_pt_br
    end
    create_table :articles, :force => true do |t|
      t.string :title_sv, :title_en, :title_fi, :title_pt_br
      t.string :body_sv, :body_en, :body_fi, :body_pt_br
    end
  end
end

I18n.load_path << "spec/app/sv.yml"
