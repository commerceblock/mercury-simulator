#!/usr/bin/env bash

if [ -z "$1" ]; then
      echo "Please use one of the following:"
      echo "init - initialize stack, create required dirs"
      echo "update - update docker images"
      echo "start - start stack to create or update services"
      echo "stop - stop stack and services, requires init again"
      echo "stopService - remove idividual service"
      echo "stackStatus - check status of the stack"
      echo "stackPs - check process list of the stack"
      echo "status - check status of running containers"
      echo "ping - ping mercury server API"
fi

function initialize(){
    echo "Creating swarm"
    docker swarm init
    echo "Creating required dirs"
    mkdir -p data/{bitcoin,mercurydb}
    echo "Downloading required docker images"
    docker pull timescale/timescaledb:latest-pg12
    docker pull commerceblock/mercury:latest
    docker pull paulius6/bitcoin:0.20.0
}

function updateDockerImages(){
    echo "Updating docker images"
    docker pull timescale/timescaledb:latest-pg12
    docker pull commerceblock/mercury:latest
    docker pull paulius6/bitcoin:0.20.0
}

function startStack(){
    echo "Starting/updating stack"
    docker stack deploy -c stack.yml sim
}

function stackRemove(){
    echo "Removing stack"
    docker stack rm sim
    sudo rm -rf data/{bitcoin,mercurydb}
}

function removeService(){
    if [ -z "$2" ]; then
          echo "Please provide service name, e.g: mercury, bitcoin"
          exit 0
    fi

    service=$2
    echo "Removing service: sim_${service}"
    docker service rm sim_${service}
}

function stackStatus(){
    echo "Stack satus:"
    echo "---"
    docker stack ls
    echo "Service status:"
    echo "---"
    docker service ls
}

function stackProcessList(){
    echo "Stack process list:"
    echo "---"
    docker stack ps sim
}

function containerStatus(){
    echo "Container status:"
    echo "---"
    docker ps --filter "name=sim_"
}

function mercuryStatus(){
    echo "Pinging mercury API"
    echo "---"
    curl -v4 http://0.0.0.0:18000/ping
    echo ""
    echo "You should see: |HTTP/1.1 200 OK| in the above response"
}

case "$1" in
        init)
            initialize
            ;;
        start)
            startStack
            ;;
        update)
            updateDockerImages
            ;;
        stop)
            stackRemove
            ;;
        stopService)
            removeService $1 $2
            ;;
        stackStatus)
            stackStatus
            ;;
        stackPs)
            stackProcessList
            ;;
        status)
            containerStatus
            ;;
        ping)
            mercuryStatus
            ;;
        *)
            "$@"

esac
