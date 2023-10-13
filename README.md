# Prerequisite

- Kubernetes CLI (kubectl)
- Minikube
- Docker (for deployment demo)

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

# Credits

Samples for deployment are forked from [Dan Wahlin's repository](https://github.com/DanWahlin/DockerAndKubernetesCourseCode/tree/main/samples/deployments/node-app).

Samples for Helm are from [Phillip Colignon's Helm Demo](https://github.com/phcollignon/helm3), simplified and adjusted.
