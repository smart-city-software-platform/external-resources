# Running bus script

## Setup

* Install Ruby 2.3.0
* Install the required gems: `bundle install`

## Start collector

In order to run the script to collect data from 
[Olho Vivo API](http://www.sptrans.com.br/desenvolvedores/APIOlhoVivo.aspx)
you need to set a environment variable with the host of Resource Adaptor.
Thus, you may run the following:
```
ADAPTOR_HOST=localhost:3002 ruby bus_line.rb
```

## TODO

* Serialize data to store the relation between bus id and resource uuid
