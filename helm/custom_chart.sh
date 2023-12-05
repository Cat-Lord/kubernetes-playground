#!/bin/bash


print_and_wait -C "Installing application via a custom chart."
echo

print_and_wait "Let's reveal the application folder structure:"
execute_command tree app
print_and_wait "Notice that we have two charts v1 and v2, we will later play around with deployment history and rollbacks."
echo

print_and_wait "First we build a docker container with our sample app. Let's create version 1.0 and also a version 1.1 upfront."
execute_command docker build -t catlord/sample-app:1.0 app/code
execute_command docker build -t catlord/sample-app:1.1 app/code

print_and_wait "Now we can install the first version"
APP_NAME="guestbook-test-1"
execute_command cat app/chart_v1/Chart.yaml
execute_command helm install ${APP_NAME} app/chart_v1

print_and_wait "Kubernetes cluster check:"
execute_command kubectl get all

print_and_wait "And now let's upgrade to version 2 instead of an installation. We will immediately run 'kubectl get pods' to watch how they are being recreated (continue with CTRL + C)."
execute_command cat app/chart_v2/Chart.yaml
execute_command helm upgrade ${APP_NAME} app/chart_v2
execute_command --no-wait "kubectl get pods --watch"

print_and_wait "Notice that the helm installation has the number of revision set to 2 this time because of the upgrade."
execute_command helm status ${APP_NAME}

print_and_wait "This spun-up a frontend service with all the following resources"
execute_command kubectl get all

print_and_wait "A list of all changes can be viewed similarly to a traditional 'rollout history' command in K8s:"
execute_command helm history ${APP_NAME}

print_and_wait "Notice the revision number- we can use it to rollback to a specific revision"
execute_command helm rollback ${APP_NAME} 1
print_and_wait "The rollback is then written as a new release, as expected:"
execute_command helm history ${APP_NAME}

print_and_wait "The cleanup process is really simple. Let helm delete the resources, let's see it in action (quit with CTRL + C)"
execute_command helm uninstall ${APP_NAME}
execute_command --no-wait kubectl get pods --watch
execute_command docker image rm catlord/sample-app:1.0
execute_command docker image rm catlord/sample-app:1.1
