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

task :default
