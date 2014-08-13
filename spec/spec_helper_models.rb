RSpec.configure do |config|
  config.before(:each) do
    # Clear class state before each spec.
    Object.send(:remove_const, "Post")
    Object.send(:remove_const, "SubPost")
    load "app/post.rb"

    # Known state.
    I18n.default_locale = :sv
  end
end

# Test against real ActiveRecord models.
# Very much based on the test setup in
# https://github.com/iain/translatable_columns/

require "active_record"
require "app/post.rb"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

silence_stream(STDOUT) do
  ActiveRecord::Schema.define(version: 0) do
    create_table :posts, force: true do |t|
      t.string :title_sv, :title_en, :title_pt_br
      t.string :body_sv, :body_en, :body_pt_br
    end
  end
end

I18n.load_path << "spec/app/sv.yml"
