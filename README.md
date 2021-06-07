# mercury-tests
Integration tests for mercury

## Usage

```bash
./sim.sh 

init - run once, first step to prepare stack
start <stack.yml> - start stack to create or update services - default: stack.yml
update - update the docker images
stop - stop stack and services
stopService <service> - remove individual service
stackStatus - check status of the stack
stackPs - get the processs list of the stack
status - check status of running containers
ping - ping mercury server API
pingLockbox <0 or 1> - ping lockbox API for lockbox server 0 or 1 - default: 0
```


