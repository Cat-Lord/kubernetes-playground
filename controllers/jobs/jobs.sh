#!/bin/bash


function print_job_logs() {
  SELECTOR="$1"
  print_and_wait "Pods created:"
  execute_command kubectl get pods -l type=$SELECTOR
  
  print_and_wait "Logs from these pods:"
  for pod in `kubectl get pods -l type=$SELECTOR -o name --no-headers=true`; do
    execute_command kubectl logs $pod
  done
}

print_and_wait -C "Jobs & Cron Jobs"

print_and_wait "Let's start with a basic job"
execute_command cat basic.job.yaml

print_and_wait "We'll create it and then see logs and completion status"
execute_command kubectl create -f basic.job.yaml
print_and_wait "Now wait a few seconds to see the jobs being completed. Continue with CTRL+C."
execute_command kubectl get jobs -w

print_and_wait "Jobs have a little bit different output when we query to get them, as you can see above."
print_job_logs basic-job

print_and_wait "If pods fail, they will be rescheduled and ran again. With the backoffLimit attribute we can restrict number of tries and resolve into failure. Let's demonstrate that on the following (intentionally corrupted) manifest:"
execute_command cat failed.job.yaml
print_and_wait "After deployment we will immediatelly jump into pod watch mode. Wait for the 3 pods to be created (and fail) and continue with CTRL+C."
execute_command kubectl create -f failed.job.yaml
execute_command --no-wait kubectl get pods -l type=fail-job -w
print_job_logs fail-job
echo
print_and_wait "The job will stay in the cluster until we decide to delete it. Deleting it will also remove the pods. We'll do that at the end."
print_and_wait "Let's clear the screen and continue"

print_and_wait -C "Jobs can run in parallel for quicker execution. This depends on our use case, but it's simply achieved like this:"
execute_command cat parallel.job.yaml
execute_command kubectl create -f parallel.job.yaml
execute_command kubectl get pods -l type=parallel-job -w
print_and_wait "We can see lots of pods being created and completed, which happens in parallel based on our configuration."
execute_command kubectl get job parallel-job
print_and_wait "Let's clear the screen again and move to the last example."

print_and_wait -C "Now we can try a cron job instead"
execute_command cat cron.job.yaml
execute_command kubectl apply -f cron.job.yaml

print_and_wait "Notice the resource has a little different label"
execute_command kubectl get cronjobs

print_and_wait "Since the job runs every minute, we might need to wait a little until it gets invoked. We can use the --watch option to see when it is triggered (continue with CTRL+C)."
execute_command kubectl get cronjobs --watch
print_job_logs cronjob

print_and_wait "We can inspect useful details about a cronjob (or plain job for that matter) with describe. The info in the describe depends on if the job already ran or not (we might see many <unset> values in that case)."
execute_command kubectl describe cronjob basic-cronjob

print_and_wait "Cleanup"
execute_command kubectl delete -f basic.job.yaml
execute_command kubectl delete -f failed.job.yaml
execute_command kubectl delete -f parallel.job.yaml
execute_command kubectl delete -f cron.job.yaml
