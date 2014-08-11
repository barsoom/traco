# This benchmark tests how fast a Traco-wrapped attribute is
# compared to the plain Active Record attribute.

require "bundler/setup"
require "benchmark/ips"
require "active_record"
require "traco"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

I18n.enforce_available_locales = false
I18n.available_locales = [ :en, :de, :sv ]
I18n.default_locale = :en
I18n.locale = :sv

COLUMNS = %w(title body long_title seo_title)

silence_stream(STDOUT) do
  ActiveRecord::Schema.define(version: 0) do
    create_table :posts, force: true do |t|
      I18n.available_locales.each do |locale|
        COLUMNS.each do |column|
          t.string "#{column}_#{locale}"
        end
      end
    end
  end
end

class Post < ActiveRecord::Base
  translates *COLUMNS
end

post = Post.new(title_en: "hello", title_sv: "Hej")

Benchmark.ips do |x|
  x.report("activerecord") { post.title_sv }
  x.report("traco") { post.title }

  x.compare!
end
