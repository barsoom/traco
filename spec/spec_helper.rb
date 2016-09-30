require "i18n"

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

I18n.enforce_available_locales = false
