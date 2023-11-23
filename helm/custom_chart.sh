#!/bin/bash


print_and_wait -c "Installing application via a custom chart."

print_and_wait "Let's reveal the chart for that application"
execute_command tree app
execute_command cat app/chart_v1/Chart.yaml

print_and_wait "First we build a docker container with our sample app. Let's create version 1.0 and also a version 1.1 upfront."
execute_command docker build -t catlord/sample-app:1.0 app/code
execute_command docker build -t catlord/sample-app:1.1 app/code

print_and_wait "Now we can install the first version"
execute_command cat app/chart_v1/Chart.yaml
execute_command helm install guestbook-test-1 app/chart_v1

print_and_wait "Kubernetes cluseter check:"
execute_command kubectl get all

print_and_wait "And now let's upgrade it instead of an installation and immediately run kubectl get pods to watch how they are being recreated (continue with CTRL + C)"
execute_command cat app/chart_v2/Chart.yaml
execute_command helm upgrade guestbook-test-1 app/chart_v2
echo 'kubectl get pods --watch'
kubectl get pods --watch

print_and_wait "Notice that the helm installation has the number of revision set to 2 this time because of the upgrade."
execute_command helm status guestbook-test-1

print_and_wait "This spun-up a frontend service with all the following resources"
execute_command kubectl get all

print_and_wait "This is the list of all changes:"
execute_command helm history guestbook-test-1

print_and_wait "Notice the revision number- we can use it to rollback to that revision"
execute_command helm rollback guestbook-test-1 1
print_and_wait "The rollback is then written as a new release, as expected:"
execute_command helm history guestbook-test-1

print_and_wait "The cleanup process is really simple. Let helm delete the resources, let's see it in action (quit with CTRL + C)"
execute_command helm uninstall guestbook-test-1
echo 'kubectl get pods --watch'
kubectl get pods --watch
