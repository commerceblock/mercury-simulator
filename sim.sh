#!/usr/bin/env bash

if [ -z "$1" ]; then
      echo "Please use one of the following:"
      echo "init - initialize stack, create required dirs"
      echo "update - update docker images"
      echo "start - start stack to create or update services"
      echo "stop - stop stack and services, requires init again"
      echo "stopService - remove individual service"
      echo "stackStatus - check status of the stack"
      echo "stackPs - check process list of the stack"
      echo "status - check status of running containers"
      echo "ping - ping mercury server API"
      echo "pingLockbox - ping lockbox server API"
      echo "pingElectrumx - check electrumx port"
fi

function initialize(){
    echo "Creating swarm"
    docker swarm init
    echo "Creating required dirs"
    mkdir -p data/{bitcoin,mercurydb,electrumx-test,lockbox_0,lockbox_1}
    echo "Downloading required docker images"
    docker pull timescale/timescaledb:latest-pg12
    docker pull commerceblock/mercury:latest
    docker pull paulius6/bitcoin:0.20.0
    docker pull lockbox:test_replica
    docker pull paulius6/electrumx
}

function updateDockerImages(){
    echo "Updating docker images"
    docker pull timescale/timescaledb:latest-pg12
    docker pull commerceblock/mercury:latest
    docker pull paulius6/bitcoin:0.20.0
    docker pull lockbox:test_replica
    docker pull paulius6/electrumx
}

function startStack(){
    if [ -z "$2" ]; then
	stackfile=stack.yml
    else
	stackfile=$2
    fi
    
    echo "Starting/updating stack"
    docker stack deploy -c $stackfile sim
}

function stackRemove(){
    echo "Removing stack"
    docker stack rm sim
    sudo rm -rf data/{bitcoin,mercurydb,electrumx-test,lockbox_0,lockbox_1}
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

function createService(){
    if [ -z "$2" ]; then
          echo "Please provide service name, e.g: mercury, bitcoin"
          exit 0
    fi

    service=$2
    echo "Creatting service: sim_${service}"
    docker compose -f stack.yml up ${service}
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

function lockboxStatus(){
    if [ -z "$2" ]; then
	lb_index=0
    else
	lb_index=1
    fi
    echo "Pinging lockbox API ${lb_index}"
    echo "---"
    curl -v4 http://0.0.0.0:1900${lb_index}/ping
    echo ""
    echo "You should see: |HTTP/1.1 200 OK| in the above response"
}

function electrumxStatus(){
    echo "Checking electrumx TCP port"
    echo "---"
    nc -vz 0.0.0.0 50001
    echo ""
    echo "You should see: Connection to 0.0.0.0 50001 port [tcp/*] succeeded!"
}

case "$1" in
        init)
            initialize
            ;;
        start)
            startStack $1 $2
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
        pingLockbox)
            lockboxStatus $1 $2
            ;;
        pingElectrumx)
            electrumxStatus
            ;;
        *)
            "$@"

esac
