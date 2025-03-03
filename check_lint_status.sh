#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <workflow_file> <branch> <job_name>"
  exit 1
fi

WORKFLOW_FILE=$1
BRANCH=$2
JOB_NAME=$3

REPO=${GITHUB_REPOSITORY}
GITHUB_TOKEN=${GITHUB_TOKEN}

echo "Проверяем статус job '${JOB_NAME}' в workflow '${WORKFLOW_FILE}' для ветки '${BRANCH}' в репозитории '${REPO}'..."

workflow_run_response=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/${REPO}/actions/workflows/${WORKFLOW_FILE}/runs?branch=${BRANCH}&per_page=1")
run_id=$(echo "$workflow_run_response" | jq -r '.workflow_runs[0].id')

if [ -z "$run_id" ] || [ "$run_id" == "null" ]; then
  echo "Не найден последний запуск workflow '${WORKFLOW_FILE}' для ветки '${BRANCH}'"
  exit 1
fi

echo "ID последнего запуска workflow: $run_id"

jobs_response=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/${REPO}/actions/runs/${run_id}/jobs")

job_conclusion=$(echo "$jobs_response" | jq -r --arg JOB_NAME "$JOB_NAME" '.jobs[] | select(.name==$JOB_NAME) | .conclusion')

if [ -z "$job_conclusion" ] || [ "$job_conclusion" == "null" ]; then
  echo "Job с именем '${JOB_NAME}' не найден в запуске ${run_id}"
  exit 1
fi

echo "Результат job '${JOB_NAME}': $job_conclusion"
if [ "$job_conclusion" != "success" ]; then
  echo "Job '${JOB_NAME}' не завершился успешно. Деплой прерван."
  exit 1
fi
