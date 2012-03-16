require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :prepare do
  unless File.exists?("spec/dummy/db/test.sqlite3")
    puts "Setting up sqlite test database..."
    system("cd spec/dummy; rake db:migrate db:test:prepare") || exit(1)
  end
end

task :default => [ :prepare, :spec ]
