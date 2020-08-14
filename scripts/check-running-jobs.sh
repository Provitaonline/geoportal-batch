#!/bin/bash

JOBS=$(aws batch list-jobs --job-queue $jobqueue --job-status "RUNNING" | jq '[.jobSummaryList[].jobId]|@sh'|sed s/\"//g|sed s/\'//g)

if [[ -n "$JOBS" ]]; then
  MATCHES=$(aws batch describe-jobs --jobs $JOBS | jq "[.jobs[] | select (.parameters.inputFile==\"$1\")] | length")
  if [[ "$MATCHES" > 1 ]]; then
    echo "job terminated, there is a job is already running against the file $1"
    exit
  fi
fi
