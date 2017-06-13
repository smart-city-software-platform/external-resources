root = ::File.dirname(__FILE__)
require ::File.join( root, 'app' )

ENV["ADAPTOR_HOST"] ||= "localhost:3002"

map('/actuate') { run Example }
map('/') { run ActuatorServer }
