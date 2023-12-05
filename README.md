# Prerequisite

- Kubernetes CLI (kubectl)
- Minikube
- Docker (for deployment demo)
- Helm

# About

This is a kubernetes playground. Different Kubernetes topics were manually tested and later documented as shell scripts. Running the scripts
is simple: run the start script in the project root folder. The execution will often pause and wait for your input to continue. This is done 
to make sure you have time to read the command output and to know what's happening and what to expect next.

To identify waiting state easily, every time user needs to press a key to continue, the line will start with '>' symbol:

```bash
> Pod sample where we create and delete a pod. Press any key to start
List of all pods
> $ kubectl get pods
```

Sometimes there will be commands executed without your intervetion.

## Running scripts separately

You can run the scripts separately but you need to provide them with functions that are grouped in the `./config/cli_utils.sh` script. This can be simply done by sourcing
the script as shown below:

```bash
$ source .config/cli_utils.sh     # from the root directory
$ source .config/prepare.sh
$ cd some-topic/
$ ./example.sh                    # avoid doing some-topic/example.sh as described below
``` 

It's also common to alias `kubectl` command to `k`:

```bash
$ alias k=kubectl
```

### Never execute scripts with relative path (IMPORTANT)

Make sure you always navigate to the directory of a script you would like to run. So when you want to run `jobs/jobs.sh`, make sure to execute `cd ./jobs` first. 
This applies to any script (yes, even in sub-directories).

### Script naming

When you are creating new scripts that should be run as K8s examples, make sure to name them as `<script-name>.sh`. If you have any scripts that you need to use 
within any of the examples (e.g. start script copied into a custom container) ensure that the name of the script doesn't end with `.sh`, because the automated
start script in this playground searches for such scripts and adds them to a list of executable examples.

> Incorrect example:
```
-- HelloWorld
 - script.sh
 - docker
 -- Dockerfile
 -- start.sh      # this should be copied to a container, but the name mustn't end with '.sh'
```

> Better example:
```
-- HelloWorld
 - script.sh
 - docker
 -- Dockerfile
 -- start         # rename this script in the Dockerfile if needed
```

# Credits

Samples for deployment are forked from [Dan Wahlin's repository](https://github.com/DanWahlin/DockerAndKubernetesCourseCode/tree/main/samples/deployments/node-app).

Samples for Helm are from [Phillip Colignon's Helm Demo](https://github.com/phcollignon/helm3), simplified and adjusted.

Ingress examples use adjusted hello-app from [Google samples](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples).

Yaml files based on the dynamic provisioning using local environment by [Rancher's Local Path Provisioner](https://github.com/rancher/local-path-provisioner).

# Future Improvements

## Unifying scripts
Check if there are any manually echo-ed commands which previously had issues with "print_and_wait" or "execute_command".

## Easy start-script navigation
Currently we have the option to pause, stop or continue script execution with the start script. The idea is to introduce a "BACK" and "FORWARD" mechanism similar
to a common music player. User would be able to:
- go back to previous script
- see list of all scripts
- go to the next script
- repeat the current script
- end

## Warning feature
Command `print_and_wait` can clear the screen. It highlights different types of outputs (command, text, command output). Introducing a switch that will highlight a warning
can increase the chance that users avoid accidentally missing it and wondering why do some commands fail.
The option could be named `--warn` shortened to `-w` (needs verification).

# Known Issues
- Reading characters with bash read behaves strangely when pressing arrow up on the keyboard. It might be related to the colored output formatting (https://superuser.com/a/1368273). 
- Sometimes deletion of resources can take a long time. We can interrupt this by pressing CTRL+C while keeping the termination in place.
