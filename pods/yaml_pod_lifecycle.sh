#!/bin/bash




print_and_wait "Here we create a pod using a YAML definition instead of manually issuing commands. Dry-run displays what would happen but it won't be actually executed."
execute_command kubectl create -f nginx.pod.yaml #--dry-run=client

print_and_wait "Now we will delete the created pod using the same approach."
execute_command kubectl delete -f nginx.pod.yaml
