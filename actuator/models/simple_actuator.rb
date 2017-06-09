#!/usr/bin/env ruby
#encoding: utf-8

require 'rubygems'
require 'date'
require 'json'
require 'rest-client'

class SimpleActuator 
  attr_accessor :uuid, :lat, :lon, :description, :capabilities, :status
  attr_accessor :semaphore, :illuminate
  attr_accessor :subscription_id, :url

  def initialize(params={})
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
    self.url = "http://localhost:9292/actuate" unless self.url
    self.status = "active"
		self.semaphore = "default"
		self.illuminate = "default"
		self.lat = "-23.558871"
		self.lon = "-46.731470"
    self.description = "A very simple actuator"
    self.capabilities = ["semaphore", "illuminate"]
  end

  def data
    {
      lat: self.lat,
      lon: self.lon,
      description: self.description,
      capabilities: self.capabilities,
      status: self.status
    }
  end

  def register
    begin
      "Registering the actuator"

      response = RestClient.post(
        ENV["ADAPTOR_HOST"] + "/components",
        {data: self.data}
      )
      self.uuid = JSON.parse(response.body)['data']['uuid']
      return true
    rescue RestClient::Exception => e
      puts "Could not register resource: #{e.response}"
      return false
    end
  end

  def subscribe
    begin
      "Subscribing to receive commands through the webhook"

      subscription_data = {
        uuid: self.uuid,
        capabilities: self.capabilities,
        url: self.url
      }

      response = RestClient.post(
        ENV["ADAPTOR_HOST"] + "/subscriptions",
        {subscription: subscription_data}
      )
      self.subscription_id = JSON.parse(response.body)['subscription']['id']
      return true
    rescue RestClient::Exception => e
      puts "Could not subscribe webhook: #{e.response}"
      return false
    end
  end

  def print_current_status
    puts "===CURRENT STATUS==="
    puts "Semaphore: #{self.semaphore}"
    puts "Illumination: #{self.illuminate}"
    puts "===END OF STATUS==="
  end
end

