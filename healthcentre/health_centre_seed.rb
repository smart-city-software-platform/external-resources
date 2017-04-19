require 'csv'
require_relative 'utils'


db = DB.new

health_centre_csv_path = File.join(__dir__, "csv/health_centres.csv")
health_centre_types_csv_path = File.join(__dir__, "csv/health_centres_types.csv")
specialties_csv_path = File.join(__dir__, "csv/specialties.csv")
types_csv_path = File.join(__dir__, "csv/type.csv")
data_csv_path = File.join(__dir__, "csv/data.csv")

puts "LOAD HEALTH_CENTRES: "
CSV.foreach(health_centre_csv_path, :headers => true) do |row|
  description = "Health Centre with CNES #{row[0]} NAME #{row[1]} BEDS #{row[2]}"
  hc = HealthCentre.new cnes: row[0], description: description
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


# CONVERT LAT AND LONG TO INTEGER WITHOUT '.'

def convert_geo value
  # TODO: fix precision remove dots
  value.to_f
end

puts "SEND PROCEDURE DATA"
count = 0
CSV.foreach(data_csv_path, :headers => true) do |row|
  break if count == 20
  specialty_id = row[11].to_i
  if specialty_id < 10
   p = Procedure.new(cnes_id: row[6], specialty: db.specialties[specialty_id.to_s].name,
                     date: Date.parse(row[8]), gender: row[2],
                     different_district: row[12],
                     lat: convert_geo(row[0]),
                     long: convert_geo(row[1]))

   hc = db.health_centres[p.cnes_id]

   hc.update lat: convert_geo(row[4]), lon: convert_geo(row[5])
   hc.register
   # THIS CAN BE CHANGED
   hc.send_data value: p.to_hash, date: p.date
   print "."
   count += 1
  end
end

db.save

# TODO: UPDATE HEALTH_CENTRE SPECIATIES
