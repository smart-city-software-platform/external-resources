#!/usr/bin/env ruby
#encoding: utf-8

require 'rubygems'
require 'date'
require 'json'
require 'rest-client'

ENV["ADAPTOR_HOST"] ||= "localhost:3002"


# CLASSES

class Common
  def initialize params
    self.update params
  end

  def update params
    params.each{|key,value| instance_variable_set("@#{key}", value)}
  end

  def get_values
    {name: self.name, id: self.id}
  end
end


class Specialty < Common
  attr_accessor :name, :id
end

class Type < Common
  attr_accessor :id, :name
end

class Procedure < Common
  attr_accessor :cnes_id, :specialty, :date, :gender, :different_district, :lat , :long

  def to_hash
    {
      "cnes_id": self.cnes_id.to_s,
      "specialty": self.specialty.to_s,
      "gender": self.gender.to_s,
      "different_district": self.different_district.to_s,
      "lat": self.lat.to_s,
      "long": self.long.to_s
    }
  end

end

class HealthCentre < Common
  attr_accessor :uuid, :cnes
  attr_accessor :types
  attr_accessor :specialties
  attr_accessor :lat, :lon, :description, :capabilities, :status

  def initialize(params={})
    params.each{|key,value| instance_variable_set("@#{key}", value)}
    # TODO: FIX SPECIALTIES
    self.types ||= Array.new
    self.specialties ||= Array.new
    self.status = "active"
    self.capabilities = ['medical_procedure']
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

  def get_values
    self.data.merge({uuid: self.uuid, cnes: self.cnes })
  end

  def register
    begin
      if self.uuid.nil? || self.uuid.empty?
        response = RestClient.post(
          ENV["ADAPTOR_HOST"] + "/components",
          {data: self.data}
        )
        self.uuid = JSON.parse(response.body)['data']['uuid']
        return true
      end
    rescue RestClient::Exception => e
      puts "Could not register resource: #{e.response}"
      return false
    end

    return false
  end

  def send_data(params)
    value = params[:value].to_s
    timestamp = params[:date].to_s
    capability = "medical_procedure"
    puts value, timestamp

    data_json = {}
    data_json[capability] = [{value: value, timestamp: timestamp}]
    begin
      response = RestClient.post(
        ENV["ADAPTOR_HOST"] + "/components/#{self.uuid}/data",
        {data: data_json}
      )
      puts "Success in post data"
    rescue RestClient::Exception => e
      # puts "Could not send data: #{e.response}"
    end
  end
end

# DATA BASE CLASS

class DB
  attr_accessor :health_centres
  attr_accessor :specialties
  attr_accessor :types

  def initialize
    self.health_centres ||= Hash.new
    self.specialties ||= Hash.new
    self.types ||= Hash.new
    self.load
  end

  def data
    {
     health_centres: self.health_centres.each{|k,v|
        self.health_centres[k] = v.get_values},
     specialties: self.specialties.each{|k,v| self.specialties[k] =  v.get_values},
     types: self.types.each{|k,v| self.types[k] = v.get_values}
    }
  end

  def path
    File.expand_path File.dirname(__FILE__) +"/db.txt"
  end

  def load
    puts ("LOADING")
    return false if not File.exists?(self.path)
    File.open(self.path, 'r') {|f|
      data = f.read
      data = JSON.parse data
      data["health_centres"].each{|k,v| self.health_centres[k] = HealthCentre.new(v)}
      data["specialties"].each{|k,v| self.specialties[k] = Specialty.new(v)}
      data["types"].each{|k,v| self.types[k] = Type.new(v)}
    }
  end

  def save
    File.open(self.path, 'w') {|f| f.write self.data.to_json}
  end

  def get_data_from uuid
    self.data[uuid]
  end

  def save_data_to uuid, params
    self.data[uuid] = params
  end

end
