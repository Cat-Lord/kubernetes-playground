# Prerequisite

- Kubernetes CLI (kubectl)
- Minikube
- Docker (for deployment demo)
- Helm

# About

This is a kubernetes playground. I tested multiple things manually and documented it as shell scripts. Running the scripts
is simple: run the script and when the exection pauses, press any key to continue (e.g. enter). This is done to make sure you
have time to read the command output or to know what's happening and what to expect next.

To identify waiting state easily, every time user needs to press a key to continue, the line will start with '>' symbol:

```bash
> Pod sample where we create and delete a pod. Press any key to start
List of all pods
> $ kubectl get pods
```

# Important note

Make sure you always navigate to the directory of a script you would like to run. So when you want to run `jobs/jobs.sh`, make sure to `cd` into `./jobs` first. This applies to any script (yes, even in sub-directories).

# Credits

Samples for deployment are forked from [Dan Wahlin's repository](https://github.com/DanWahlin/DockerAndKubernetesCourseCode/tree/main/samples/deployments/node-app).

Samples for Helm are from [Phillip Colignon's Helm Demo](https://github.com/phcollignon/helm3), simplified and adjusted.

Ingress examples use adjusted hello-app from [Google samples](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples).
