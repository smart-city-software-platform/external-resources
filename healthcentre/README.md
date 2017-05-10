# Running healthcentre script

## Setup

* Install Ruby 2.3.0
* Install the required gems: `bundle install`

## Start collector

In order to run the script to populate the platform, you need set a environment
variable with the host of Resource Adaptor.

```
ADAPTOR_HOST=localhost:3002 ruby health_centre.rb
```
