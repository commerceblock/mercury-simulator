#!/usr/bin/env bash

if [ -z "$1" ]; then
      echo "Please use one of the following:"
      echo "initialize - run once, first step"
      echo "start - start stack to create or update services"
      echo "stop - stop stack and services"
      echo "stopService - remove idividual service"
      echo "stackStatus - check status of the stack"
      echo "status - check status of running containers"
      echo "ping - ping mercury server API"
fi

function initialize(){
    echo "Creating swarm"
    docker swarm init
    echo "Creating required dirs"
    mkdir -p data/{bitcoin,mercurydb}
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

function containerStatus(){
    echo "Container status:"
    echo "---"
    docker ps --filter "name=sim_"
}

function mercuryStatus(){
    echo "Pinging mercury API"
    echo "---"
    curl -v4 http://0.0.0.0:8000/ping
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
        stop)
            stackRemove
            ;;
        stopService)
            removeService $1 $2
            ;;
        stackStatus)
            stackStatus
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
