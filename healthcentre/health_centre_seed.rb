require 'csv'
require 'geocoder'
require 'faker'
require_relative 'utils'

def lat_range (min=-23.69, max=-23.44)
    rand * (max-min) + min
end

def lon_range (min=-46.36, max=-46.84)
    rand * (max-min) + min
end

def my_db

  db = DB.new

  health_centre_csv_path = File.join(__dir__, "csv/health_centres.csv")
  health_centre_types_csv_path = File.join(__dir__, "csv/health_centres_types.csv")
  specialties_csv_path = File.join(__dir__, "csv/specialties.csv")
  types_csv_path = File.join(__dir__, "csv/type.csv")

  puts "LOAD HEALTH_CENTRES: "
  CSV.foreach(health_centre_csv_path, :headers => true) do |row|
    description = "Health Centre with CNES #{row[0]} NAME #{row[1]} BEDS #{row[2]}"
    hc = HealthCentre.new cnes: row[0], description: description, lat: lat_range , lon: lon_range
    db.health_centres[hc.cnes] = hc
    print "."
  end

  puts "LOAD SPECIALTIES: "
  CSV.foreach(specialties_csv_path, :headers => false) do |row|
    s = Specialty.new id: row[0], name: row[1]
    db.specialties[s.id] = s
    print "."
  end

  puts "LOAD HEALTH CENTRE TYPE: "
  CSV.foreach(types_csv_path, :headers => false) do |row|
    t = Type.new(id: row[0], name: row[1])
    db.types[t.id] = t
    print "."
  end

  puts "ASSOCIATE TYPE WITH HEALTHCENTRE: "
  CSV.foreach(health_centre_types_csv_path, :headers => false) do |row|
    t = db.types[row[1]]
    hc = db.health_centres[row[0]]
    hc.types << t
    print "."
  end

  db

end

########################
# Random Procedures code


def send_procedure db
  lat = lat_range
  long = lon_range
  hc = db.health_centres.values.sample
  p = Procedure.new(cnes_id: hc.cnes, 
                     specialty: db.specialties.values.sample.name,
                     date: Faker::Time.between(Date.today-900, Date.today-700), 
                     gender: ['M','F'].sample,
                     different_district: Faker::Name.last_name,
                     lat: lat,
                     long: long)
  hc.register
  hc.send_data value: p.to_hash, date: p.date
end

def seed n=5
  puts "SEEDING: "   
  db = my_db
  for x in 0..n
    send_procedure db
    print '.'
  end
  db.save
end

seed 20 
