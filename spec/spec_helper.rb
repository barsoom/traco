require "i18n"

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
end

I18n.enforce_available_locales = false

I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
