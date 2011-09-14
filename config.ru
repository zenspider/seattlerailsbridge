# -*- ruby -*-

require './railsbridge'
use Rack::ShowExceptions
use Rack::ShowStatus
use Rack::Static, :urls => ["/css", "/img"], :root => "public"

run RailsBridge
