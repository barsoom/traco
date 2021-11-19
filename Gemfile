source "https://rubygems.org"

# Specify your gem's dependencies in the .gemspec.
gemspec

group :benchmark do
  gem "benchmark-ips"
end

group :development do
  gem "barsoom_utils", github: "barsoom/barsoom_utils"
  gem "rubocop"
end

group :development, :test do
  gem "appraisal"
  gem "rake"
  gem "rspec"
  gem "sqlite3"
end
