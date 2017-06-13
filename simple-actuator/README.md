# Running bus script

## Setup

* Install Docker >= 17
* Install Docker Compose >= 1.10
* Run the setup script:
```
./scripts/setup
```

## Running

Start the containers with:
```
./scripts/development start
```

When you access for the first the actuator page in http://localhost:9292/actuate
the app will register a new resource in the platform as well as subscribe to
receive actuation commands for **semaphore** and **illuminate** capabilities.
After, you can post a new command to the Actuator Controller API:
> curl -H "Content-Type: application/json" -X POST -d '{"data": [{"uuid": "730fe161-0fdc-4ea7-80b6-7de4c0e65c3f","capabilities": {"semaphore": "green", "illuminate":"Low"}}]}' http://localhost:5000/commands | json_pp

Reload the actuation page to see the new values: http://localhost:9292/actuate


# TODO

* [] Support websocket to automatically reload the page on resource actuation
