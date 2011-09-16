#!/usr/bin/ruby -w

ENV['GEM_HOME'] = "tmp/isolate/ruby-1.8"
ENV.delete 'GEM_PATH'

require 'rubygems'
require 'sinatra'
require 'erb'
require 'yaml'

require 'sinatra/base'

class RailsBridge < Sinatra::Base
  helpers do
    def page locals
      if locals["content"] then
        erb(:page, :locals => locals).gsub(/<pre>/, '<pre class="term">')
      else
        erb(:goal, :locals => locals).gsub(/<pre>/, '<pre class="term">')
      end
    end

    def lesson_path n
      path = "lessons/%02d.yaml" % n
      path = nil unless File.file? path
      path
    end

    def load_lesson n
      lesson = YAML.load_file lesson_path n
      lesson["n"] = n
      lesson["section_title"] ||= nil
      lesson["section_content"] ||= ""
      lesson["skip_nav"] ||= false
      lesson
    end

    def nav n
      befor = n - 1
      after = n + 1

      r = []
      r << "<a href=\"/#{befor}\">Prev Lesson</a>" if lesson_path befor
      r << "<a href=\"/toc\">TOC</a>"
      r << "<a href=\"/#{after}\">Next Lesson</a>" if lesson_path after
      r.join " | "
    end
  end

  get '/print' do
    lessons = Dir["lessons/*.yaml"].sort.map { |f| File.basename f, ".yaml" }
    lessons.map! { |n| load_lesson n.to_i(10) }
    erb :index, :locals => { :lessons => lessons, :subtitle => "All Lessons" }
  end

  get '/toc' do
    lessons = Dir["lessons/*.yaml"].sort.map { |f| File.basename f, ".yaml" }
    lessons.map! { |n| load_lesson n.to_i(10) }

    erb :toc, :locals => {
      :lessons => lessons,
      :subtitle => "Table of Contents"
    }
  end

  get '/:id' do
    n = params[:id].to_i
    lesson = load_lesson n
    lesson["subtitle"] = "Lesson #{n}"

    page lesson
  end

  get '/' do
    redirect "/1"
  end

  run! if app_file == $0
end
