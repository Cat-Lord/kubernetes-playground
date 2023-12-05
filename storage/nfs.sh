#!/bin/bash


print_and_wait -C "Deploying and using NFS server"
echo

print_and_wait "Unfortunately, this example requires some local work in order to get it running. The steps are:"
print_and_wait "0. Install necessary NFS dependencies. Make sure to remove them if needed after the example finishes."
execute_command --no-exec sudo apt install -y nfs-common
execute_command --no-exec sudo apt install -y nfs-server
print_and_wait "1. Building local NFS server image"
print_and_wait docker build -t nfs-server:1.0 nfs/nfs-server
echo
print_and_wait "2. Running the container"
print_and_wait docker run -d --rm --privileged --name nfs-server -v /var/nfs:/var/nfs nfs-server:1.0

print_and_wait "2.b You can verify it by running:"
execute_command "docker ps | grep -i nfs-server"
echo

print_and_wait "3. Connect the NFS container to the minikube docker network."
print_and_wait docker network connect minikube nfs-server
echo

print_and_wait "Now we can get back to the script and let it do it's things :)"
print_and_wait "First we will test your activities above with a sample deployment that will print data to the NFS."
print_and_wait "The deployment will mount our NFS as a volume and log regularly into a file:"
execute_command cat nfs/busybox.deployment.yaml
execute_command kubectl create -f nfs/busybox.deployment.yaml
echo
print_and_wait "Wait for the deployment and continue with CTRL+C"
execute_command kubectl get pods -w

print_and_wait "Our pod should be running if we did everything correctly. If anything failed, we should see it in the describe output for the pod:"
execute_command kubectl describe pods
echo

print_and_wait "After some time our pod should now have logged a few messages into the NFS. Let's take a look:"
execute_command cat /var/nfs/exports/busybox.log
echo

print_and_wait "Cleanup, some operations might take some time"
execute_command kubectl delete -f nfs/busybox.deployment.yaml
execute_command docker stop nfs-server -s SIGKILL
execute_command docker image rm nfs-server:1.0
print_and_wait "You can remove the NFS binaries if necessary:"
execute_command --no-exec "sudo apt remove -y nfs-common && sudo apt remove -y nfs-server"
