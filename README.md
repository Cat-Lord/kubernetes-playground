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
$ cd some-topic/
$ ./example.sh                    # avoid doing some-topic/example.sh as described below
``` 

It's also common to alias `kubectl` command to `k`.

### Never execute scripts with relative path (IMPORTANT)

Make sure you always navigate to the directory of a script you would like to run. So when you want to run `jobs/jobs.sh`, make sure to execute `cd ./jobs` first. 
This applies to any script (yes, even in sub-directories).

# Credits

Samples for deployment are forked from [Dan Wahlin's repository](https://github.com/DanWahlin/DockerAndKubernetesCourseCode/tree/main/samples/deployments/node-app).

Samples for Helm are from [Phillip Colignon's Helm Demo](https://github.com/phcollignon/helm3), simplified and adjusted.

Ingress examples use adjusted hello-app from [Google samples](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples).

Yaml files based on the dynamic provisioning using local environment by [Rancher's Local Path Provisioner](https://github.com/rancher/local-path-provisioner).

# Improvements

## No-wait feature
Introduce no-wait option for "execute_command" command. That way we won't have to manually echo and run the command and can still utilize syntax highlighting.

## Unifying scripts
Check if there are any manually echo-ed commands which previously had issues with 'print_and_wait' or 'execute_command'

## Easy start-script navigation
Currently we have the option to pause, stop or continue script execution with the start script. The idea is to introduce a "BACK" and "FORWARD" mechanism similar
to a common music player. User would be able to:
- go back to previous script
- see list of all scripts
- go to the next script
- repeat the current script
- end

## Keep script name displayed at all times
With the listing and skipping mechanism of the start script (go next, repeat script, ...) we can quickly get lost when we want to reference the current script. Proposal is
to include the script name always on top of the screen.
This can be achieved in a number of ways, one of which is an env variable that denotes the current script name and when a clear command is issued we will print it.

## Known Issues
- Reading characters with bash read behaves strangely when pressing arrow up on the keyboard. It might be related to the colored output formatting (https://superuser.com/a/1368273). 
