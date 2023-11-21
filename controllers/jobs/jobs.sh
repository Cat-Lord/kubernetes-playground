#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../../cli_utils.sh"

function print_job_logs() {
  print_and_wait "Pods created:"
  execute_command kubectl get pods -o name --no-headers=true
  
  print_and_wait "Logs from these pods:"
  for pod in `kubectl get pods -o name --no-headers=true`; do
    execute_command kubectl logs $pod
  done
}

print_and_wait -c "Jobs & Cron Jobs"

print_and_wait "Let's start with a basic job"
execute_command cat basic.job.yaml

print_and_wait "We'll create it and then see logs and completion status"
execute_command kubectl create -f basic.job.yaml
execute_command kubectl get jobs

print_and_wait "Jobs have a little bit different output when we query to get them, as you can see above."
print_job_logs

print_and_wait "The output of the job above should now be a bit different"
execute_command kubectl get job basic-job
execute_command kubectl delete -f basic.job.yaml

print_and_wait "Now we can try a cron job instead"
execute_command cat cron.job.yaml
execute_command kubectl apply -f cron.job.yaml

print_and_wait "Notice the resource has a little different label"
execute_command kubectl get cronjobs

print_and_wait "Since the job runs every minute, we might need to wait a little until it gets invoked. We can use the --watch option to see when it is triggered (continue with CTRL+C)."
execute_command kubectl get cronjobs --watch
print_job_logs

print_and_wait "We can inspect useful details about a cronjob (or plain job for that matter) with describe. The info in the describe depends on if the job already ran or not (we might see many <unset> values in that case)."
execute_command kubectl describe cronjob basic-cronjob

print_and_wait "Cleanup"
execute_command kubectl delete -f cron.job.yaml
