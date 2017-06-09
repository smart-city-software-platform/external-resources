#encoding: utf-8

class Example < ActuatorServer
  set :server, 'thin'
  set :connections, []

  @@actuator = nil

  get '/' do
    @@actuator = SimpleActuator.new unless @@actuator
    @@actuator.register unless @@actuator.uuid
    @@actuator.subscribe unless @@actuator.subscription_id

    #stream(:keep_open) do |out|
    #	connections << out
      # purge dead connections
    #	connections.reject!(&:closed?)
    #end
    erb :index, locals: { actuator: @@actuator }
  end

  post '/' do
    request.body.rewind  # in case someone already read it
    command = JSON.parse(request.body.read)['command']
    capability = command["capability"]
    value = command["value"]
    actuator.send(capability, value)

    actuator.print_current_status

    #connections.each do |out|
      # notify client that a new message has arrived
    #	out << capability << "|" << value
    #end

    # acknowledge
    "message received"
  end
end
