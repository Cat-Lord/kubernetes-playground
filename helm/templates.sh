#!/bin/bash

HELM_APP_SOURCE="templating/app"

print_and_wait -C "Helm Templating in action"
echo;

print_and_wait "We are going to create sample application with backend and frontend both being Nginx with a custom HTML. We will expose them with port-forward and verify it."

print_and_wait "These servers will use some templating configuration for deployment and also print out some templated messages. "
execute_command tree ${HELM_APP_SOURCE}

print_and_wait "Notice the 'values.yaml' files. These contain key-value pairs that will be used to replace placeholder values inside the manifest files."
execute_command cat ${HELM_APP_SOURCE}/charts/backend/values.yaml
execute_command cat ${HELM_APP_SOURCE}/charts/frontend/values.yaml
print_and_wait "The project root also contains a 'values.yaml' file. In case any of the properties of the sub-file are the same as in this root file, the value from the root file will be used."
execute_command cat ${HELM_APP_SOURCE}/values.yaml

print_and_wait "There are also pre-defined key-value pairs supplied by Helm, e.g. chart name via {{.Chart.Name}} placeholder."
execute_command cat ${HELM_APP_SOURCE}/charts/backend/templates/deployment.yaml

print_and_wait "We can also perform some simple string operations on our templated values as seen in a deployment file:"
execute_command cat ${HELM_APP_SOURCE}/charts/frontend/templates/deployment.yaml
print_and_wait "..or config map file:"
execute_command cat ${HELM_APP_SOURCE}/charts/frontend/templates/configmap.yaml
echo

print_and_wait "We are also able to check the installation with inserted template values before running it:"
execute_command helm template ${HELM_APP_SOURCE}

print_and_wait "The process is the same as for a traditional chart. When you execute the following command a short pause will happen, so don't panic :)"
execute_command helm install catissimo ${HELM_APP_SOURCE} --atomic
print_and_wait "Notice the 'atomic' option above. Normally if an error(s) occurs, Helm will create the installation anyway. This option prevents it."
print_and_wait "Let's confirm the installation by looking at the resources"
execute_command kubectl get all
echo

print_and_wait "Now expose the deployment and access it from the browser:"
execute_command kubectl port-forward deploy/catissimo-backend 8888:80 > /dev/null &
execute_command sensible-browser http://localhost:8888
execute_command kill %%

execute_command kubectl port-forward deploy/catissimo-frontend 9999:80 > /dev/null &
execute_command sensible-browser http://localhost:9999
execute_command kill %%

print_and_wait "And cleaning up.."
execute_command helm delete catissimo

print_and_wait "Make sure to check the files in the templating folder yourself to see more ;)"

