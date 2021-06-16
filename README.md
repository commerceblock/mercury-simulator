# mercury-tests
Integration tests for mercury

## Usage

```bash
./sim.sh 

init - run once, first step to prepare stack
initDirs - run after stop to reinitialize the data dirs
start <stack.yml> - start stack to create or update services - default: stack.yml
update - update the docker images
start - start stack to create or update services
stop - stop stack and services
stopService <service> - remove individual service
stackStatus - check status of the stack
stackPs - get the processs list of the stack
status - check status of running containers
ping - ping mercury server API
pingLockbox <0 or 1> - ping lockbox API for lockbox server 0 or 1 - default: 0
pingElectrumx - check electrumx port
```


