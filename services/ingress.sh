#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

function create_deployment_and_svc() {
  NAME="$1"
  IMAGE="$2"

  if [[ -z "$NAME" ]]; then
    echo 'Error: Function received no argument, NAME for deployment/service expected'
    echo
    return
  fi

  if [[ -z "$IMAGE" ]]; then
    IMAGE="hello-app:1.0"
  fi

  execute_command kubectl create deployment "$NAME" --image="$IMAGE"
  execute_command kubectl expose deployment "$NAME" --port=80 --target-port=8080 --type=ClusterIP
}

print_and_wait -c "Ingress config"
print_and_wait "Grab some snacks, this is going to be a long example"
echo

print_and_wait "There is a chance ingress is already prepared for us in our environment. If this wasn't the case, we would need to go to the official website to get the deployment file for all the relevant resources."
print_and_wait "Since we're using minikube, all we have to do is enable the ingress controller."
execute_command minikube addons enable ingress

print_and_wait "All the resources should be in the ingress-nginx namespace."
execute_command kubectl get all --namespace ingress-nginx
execute_command kubectl describe ingressclasses nginx

print_and_wait "To make this the default ingress class we can use annotations. It might already be set as a default, we can check in the output above. Below is a command that would add an annotation marking this the default (won't be executed)."
print_and_wait "kubectl annotate ingressclasses nginx 'ingressclass.kubernetes.io/is-default-class=true'"
echo;

# INGRESS-SINGLE
print_and_wait "Before we start with this example, we need to build the containers that will be used in following examples."
execute_command docker build -t hello-app:1.0 samples_for_ingress/hello-app
execute_command docker build -t error-app:1.0 samples_for_ingress/error-app

print_and_wait "Let's deploy a service and then access it through the ingress."
create_deployment_and_svc ha-single

print_and_wait "And now expse the ingress resource:"
execute_command cat samples_for_ingress/single.ingress.yaml
execute_command kubectl create -f samples_for_ingress/single.ingress.yaml 

print_and_wait "Creation of the ingress resources can be inspected. We should wait for the address field to be populated (continute with CTRL+C)."
execute_command kubectl get ingress --watch

INGRESS_IP=`kubectl get ingress -o jsonpath="{ .items[].status.loadBalancer.ingress[].ip }"`
print_and_wait "Now we should be able to access the ha-single deployment from outside using the IP address of the ingress above. Let's try it with curl"
execute_command curl $INGRESS_IP
echo

print_and_wait "But that's not all - we can target the ingress controller itself!"
execute_command kubectl get svc -n ingress-nginx
INGRESS_IP=`kubectl get svc -n ingress-nginx -o jsonpath="{ .items[].spec.clusterIP }"`
execute_command curl $INGRESS_IP
print_and_wait "Notice: we are able to target the port, but if we tried to target the nodePort, we would get a timeout (not demostrated here, feel free to try it yourself)"
echo

print_and_wait "Inspecting our ingress definition, we can see details such as (default) backends or rules:"
execute_command kubectl describe ingress ingress-single

print_and_wait "Now were going to deploy ingress with multiple services. Let's clear the screen..."

# INGRESS-MULTIPLE
print_and_wait -c "First let's see the ingress deployment"
execute_command cat samples_for_ingress/multiple.ingress.yaml

print_and_wait "We will first create updated versions of the containers just to have some more descriptive messages"
execute_command docker build -t hello-app-red:1.0 --build-arg "ADDITIONAL_MESSAGE=RED_ingress" samples_for_ingress/hello-app
execute_command docker build -t hello-app-blue:1.0 --build-arg "ADDITIONAL_MESSAGE=BLUE_ingress" samples_for_ingress/hello-app

print_and_wait "And create red and blue deployments with services"
create_deployment_and_svc ha-red hello-app-red:1.0
create_deployment_and_svc ha-blue hello-app-blue:1.0
create_deployment_and_svc ha-error error-app:1.0

print_and_wait "Inspecting created resources:"
execute_command kubectl get all

print_and_wait "And finally create the Ingress resource. After our new ingress resource gets an IP, continue with CTRL+C (this might take around 15 seconds)."
execute_command kubectl create -f samples_for_ingress/multiple.ingress.yaml
execute_command kubectl get ingress --watch

print_and_wait "Let's query the ingress and see what we get back. Notice that the IP is the same for both '-single' and '-multiple' ingress endpoints."
execute_command curl http://${INGRESS_IP}/red

print_and_wait "...this is weird, no? We are getting a response from the '-single' ingress instead of our '-multiple'. This is because we must provide a host name. This can be done either through DNS configuration or by using a 'Host' header in our request. We will go with the latter approach."
execute_command curl http://${INGRESS_IP}/red --header "'"Host: path.example.com"'"			# need to wrap like this because it would be stripped when passed to the execute_command function

print_and_wait "Now it works. Let's check the blue service"
execute_command curl http://${INGRESS_IP}/blue --header '"'Host: path.example.com'"'

print_and_wait "Let's also try a non-existing endpoint. We should get an error service to respond."
execute_command curl http://${INGRESS_IP}/cats --header '"'Host: path.example.com'"'

print_and_wait "Since in our configuration we used Prefix match, appending arbitrary paths to our requests will work."
execute_command curl http://${INGRESS_IP}/red/1 --header '"'Host: path.example.com'"'
execute_command curl http://${INGRESS_IP}/red/X --header '"'Host: path.example.com'"'
execute_command curl http://${INGRESS_IP}/red/more_red/most_red --header '"'Host: path.example.com'"'

print_and_wait "This won't work with Exact matches!"
execute_command curl http://${INGRESS_IP}/Blue --header '"'Host: path.example.com'"'
execute_command curl http://${INGRESS_IP}/blue/1 --header '"'Host: path.example.com'"'
execute_command curl http://${INGRESS_IP}/blue/like/an/ocean --header '"'Host: path.example.com'"'

# NAME-BASED INGRESS
print_and_wait "In a similar fashion we will deploy a name-based ingress."
print_and_wait -c "Name-based Ingress"
print_and_wait "Wait for the IP address and continue with CTRL+C as always."
execute_command cat samples_for_ingress/name-based.ingress.yaml
execute_command kubectl create -f samples_for_ingress/name-based.ingress.yaml
execute_command kubectl get ingress --watch

print_and_wait "Let's test it!"
execute_command curl http://${INGRESS_IP}/ --header '"'Host: red.example.com'"'
execute_command curl http://${INGRESS_IP}/ --header '"'Host: blue.example.com'"'
execute_command curl http://${INGRESS_IP}/sample/path/append --header '"'Host: blue.example.com'"'

print_and_wait "And if no requests match, we are using the existing '-single' resource, because it matches first, otherwise we'd use the one defined in the name-based manifest."
execute_command curl http://${INGRESS_IP}/sample/path/append --header '"'Host: unknown.example.com'"'

# TLS INGRESS
print_and_wait "Lastly, let's try out TLS. First we clear the screen"
print_and_wait -c "The first step is to generate a certificate and create a K8s secret that uses it."

execute_command openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.cert -subj '"'/C=US/ST=ILLINOIS/L=CHICAGO/O=IT/OU=IT/CN=tls.example.com'"'
print_and_wait "This created 2 new files for key and certificate"
execute_command ls -l
execute_command kubectl create secret tls self-signed-cert-secret --cert=tls.cert --key=tls.key

print_and_wait "Let's create a new docker app, deploy sample ingress TLS config and wait for an IP to be assigned. Continue with CTRL+C."
execute_command docker build -t tls-app:1.0 --build-arg "ADDITIONAL_MESSAGE=TLS_secret_app" samples_for_ingress/hello-app
execute_command cat samples_for_ingress/tls.ingress.yaml
execute_command kubectl create -f samples_for_ingress/tls.ingress.yaml
create_deployment_and_svc hello-app-tls

print_and_wait "Wait 'til our new ingress gets an IP and continue with CTRL+C (can take up to 20-30s)."
execute_command kubectl get ingress -w

print_and_wait "To curl the endpoint, we have to use the ingress IP above and also its HTTPS port. Let's get the port (IP stays the same)."
TLS_INGRESS_IP=`kubectl get ingress ingress-tls -o jsonpath='{ .status.loadBalancer.ingress[].ip }'`
HTTPS_NODEPORT=`kubectl get svc -n ingress-nginx -o jsonpath='{ .items[0].spec.ports[1].nodePort }'`

print_and_wait "Now that we have this configured, we can curl the TLS-secured service. Notice that we're using HTTPS"
execute_command curl https://tls.example.com:${HTTPS_NODEPORT}/ --resolve tls.example.com:${HTTPS_NODEPORT}:${TLS_INGRESS_IP} --insecure --verbose
print_and_wait "We've enabled verbose output to see the TLS handshake. The --resolve option serves as a in-place DNS configuration, otherwise we would've needed to adjust our local DNS settings."

print_and_wait "Cleanup !"
execute_command kubectl delete all --all --now
execute_command kubectl delete ingress --all --now
execute_command kubectl delete secret self-signed-cert-secret
execute_command rm tls.key tls.cert

execute_command docker image rm hello-app:1.0 hello-app-blue:1.0 hello-app-red:1.0 error-app:1.0 tls-app:1.0
