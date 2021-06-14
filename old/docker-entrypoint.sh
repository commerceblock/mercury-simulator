#!/bin/sh

if [ "$1" = "tests" ]; then

  # postgresql
  /etc/init.d/postgresql start
  su postgres -s /bin/bash -c "psql -f /etc/postgres-setup.txt"

  # bitcoind
  cd /srv/bitcoin
  touch /var/log/daemons/bitcoind.log
  chmod a+rw /var/log/daemons/bitcoind.log
  # commerceblock/bitcoin is at /usr/local/bin/bitcoind, official bitcoind is at /usr/bin/bitcoind
  su bitcoin -s /bin/bash -c "/usr/local/bin/bitcoind -printtoconsole -rpcallowip=0.0.0.0/0 -rpcport=8332 -server=1 -txindex=1 -prune=0 -regtest=1 -daemon=1"
  sleep 4 # wait fot the cookie file to be created
  chmod a+r /srv/bitcoin/.bitcoin/regtest/.cookie
  setfacl -m u:electrs:rx /srv/bitcoin/.bitcoin/regtest/blocks
  setfacl -m u:electrs:rx /srv/bitcoin/.bitcoin/regtest/blocks/*
  setfacl -d -m u:electrs:rx /srv/bitcoin/.bitcoin/regtest/blocks

  # mining
  touch /var/log/daemons/bitcoin-mining.log
  chmod a+rw /var/log/daemons/bitcoin-mining.log
  (
  BTC_ADDRESS=$(su bitcoin -s /bin/bash -c 'bitcoin-cli -rpccookiefile=/srv/bitcoin/.bitcoin/regtest/.cookie getnewaddress')
  while true; do
   su bitcoin -s /bin/bash -c "bitcoin-cli -rpccookiefile=/srv/bitcoin/.bitcoin/regtest/.cookie generatetoaddress 1 ${BTC_ADDRESS} &>>/var/log/daemons/bitcoin-mining.log"
   sleep 600
  done
  ) &

  # electrs connects to bitcoind
  cd /srv/electrs
  touch /var/log/daemons/electrs.log
  chmod a+rw /var/log/daemons/electrs.log
  su electrs -s /bin/bash -c "electrs --verbose --timestamp --network regtest --daemon-rpc-addr 127.0.0.1:8332 --daemon-dir /srv/bitcoin/.bitcoin &>>/var/log/daemons/electrs.log &"

  # mongo
  cd /srv/mongo
  touch /var/log/daemons/mongo.log
  chmod a+rw /var/log/daemons/mongo.log
  su mongo -s /bin/bash -c "mongod --dbpath /srv/mongo &>>/var/log/daemons/mongo.log &"
  sleep 5
  su mongo -s /bin/bash -c "cat /etc/mongo-setup.txt | mongo"

  # mainstay connects to mongo
  cd /srv/mainstay
  touch /var/log/daemons/mainstay.log
  chmod a+rw /var/log/daemons/mainstay.log
  su mainstay -s /bin/bash -c "mainstay /srv/bitcoin/.bitcoin &>>/var/log/daemons/mainstay.log &"

  # mercury connects to postgresql
  export MERC_DB_HOST_R=127.0.0.1
  export MERC_DB_PORT_R=5432
  export MERC_DB_USER_R=mercury
  export MERC_DB_PASS_R=mrc_password
  export MERC_DB_DATABASE_R=mercury
  export MERC_DB_HOST_W=127.0.0.1
  export MERC_DB_PORT_W=5432
  export MERC_DB_USER_W=mercury
  export MERC_DB_PASS_W=mrc_password
  export MERC_DB_DATABASE_W=mercury
  cd /srv/mercury
  su mercury -s /bin/bash -c "mercury &"
  
  cd /srv/tests
  shift
  exec su tester -s /bin/bash -c "$*"
elif [ "$1" = "/bin/bash" ]; then
  shift
  exec /bin/bash $*
else
  echo "To run test suite:       docker run --rm -it mercury-tests tests ./suite.py"
  echo "For shell with daemons:  docker run --rm -it mercury-tests tests /bin/bash"
  echo "For pure bash shell:     docker run --rm -it mercury-tests /bin/bash"
fi

