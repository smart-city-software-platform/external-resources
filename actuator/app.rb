#!/usr/bin/env ruby
#encoding: utf-8

require 'sinatra'

class ActuatorServer < Sinatra::Base
  helpers do
    include Rack::Utils
  end

  set :views, File.expand_path('../views', __FILE__)
end

require_relative 'models/init'
require_relative 'routes/init'
