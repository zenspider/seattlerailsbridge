require "rubygems"

begin
  require "isolate"
  require "isolate/rake"

  Isolate.now! do
    gem "rake"
    gem "sinatra"
    gem "heroku"
    gem "rdiscount"
  end
rescue LoadError
  # ignore - for heroku
end

task :default => :sync

task :sync => [:pull, :push]

task :pull do
  system "git pull --rebase heroku master"
end

task :push do
  system "git push heroku master"
end

task :logs do
  system "heroku logs"
end
