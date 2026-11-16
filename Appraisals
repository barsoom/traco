# frozen_string_literal: true

appraise "rails-8.0" do
  gem "activerecord", "~> 8.0.3"
  # Active Support 8.0 passes quirks_mode: to JSON.generate, which json 3 rejects.
  gem "json", "< 3.0"
end

appraise "rails-8.1" do
  gem "activerecord", "~> 8.1.0"
end
