# mercury-tests
Integration tests for mercury

## Building and running

First, build the docker image:

`docker build -t mercury-tests .`

Then run the test suite:

`docker run --rm -it mercury-tests tests pytest -v suite.py`

## Debugging:

* For bash shell with daemons running, use:

`docker run --rm -it mercury-tests tests /bin/bash`

* You can also execute any other command, as user 'tester':

`docker run --rm -it mercury-tests tests echo "my command"`

* For pure bash shell as root, use:

`docker run --rm -it mercury-tests /bin/bash`

## Logging

Daemon logs are saved to `/var/log/daemons/`. Mount that directory as a volume if you want the logs to persist.

