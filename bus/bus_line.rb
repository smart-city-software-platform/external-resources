#!/usr/bin/env ruby
#encoding: utf-8

require 'rubygems'
require 'date'
require 'json'
require 'rest-client'

class Bus
  
  attr_accessor :id, :line_id, :uuid
  attr_accessor :lat, :lon, :description, :capabilities, :status

  def initialize(params={})
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
    self.status = "active"
    self.description = "Bus with id #{self.id}"
    self.capabilities = ["location"]
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
      puts self.data
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

  def send_data(lat, lon, hour)
	  value = [lat, lon]
    timestamp = DateTime.now.to_s
    capability = "location"

    data_json = {}
    data_json[capability] = [{value: value, timestamp: timestamp}]
    begin
      response = RestClient.post(
        ENV["ADAPTOR_HOST"] + "/components/#{self.uuid}/data",
        {data: data_json}
      )
      puts "Success in post data"
    rescue RestClient::Exception => e
      puts "Could not send data: #{e.response}"
    end
  end
end


class BusList
  attr_accessor :buses, :lines
  def initialize
    @buses = {}
    @lines = ["2023","34791","34853","2085"]
  end

  def auth
    # token API olho vivo
    token = 'fd156f3011d240eb80d9b3c82cd1451ee8fe2a84664a03189f2a6ceb21d2cafe'
    response = RestClient.post("http://api.olhovivo.sptrans.com.br/v0/Login/Autenticar?token=#{token}", {})
    response.cookies['apiCredentials']
  end

  def get_positions
    self.lines.each do |line|
			begin
				list = JSON.parse(RestClient.get("http://api.olhovivo.sptrans.com.br/v0/Posicao?codigoLinha=#{line}", {cookies: {"apiCredentials": self.auth}}).body)
			rescue
        puts "Could not get buses positions"
				return false
			end

			list['vs'].each do |bus_info|
        if self.buses.has_key?(bus_info['p'])
          bus = buses[bus_info['p']]
        else
          bus = Bus.new(
            id: bus_info['p'], 
            line_id: line, 
            lat: bus_info['py'],
            lon: bus_info['px']
          )
          bus.register
          buses[bus.id] = bus
        end

        bus.send_data(bus_info['py'], bus_info['px'], list['hr'])
			end
    end
  end
end

list = BusList.new
list.get_positions

