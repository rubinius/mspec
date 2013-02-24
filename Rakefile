require 'bundler/gem_tasks'
require 'bundler/setup'

task :default do
  bin = File.expand_path "../bin/mspec", __FILE__
  sh "#{bin} spec"
end
