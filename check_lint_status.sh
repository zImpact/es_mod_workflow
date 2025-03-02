#!/bin/bash
# check_lint_status.sh
# Использование: ./check_lint_status.sh <workflow_file> <branch>
# Скрипт получает статус последнего запуска указанного workflow на заданной ветке.

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <workflow_file> <branch>"
  exit 1
fi

WORKFLOW_FILE=$1
BRANCH=$2
REPO=${GITHUB_REPOSITORY}
GITHUB_TOKEN=${GITHUB_TOKEN}

echo "Проверяем последний запуск workflow '${WORKFLOW_FILE}' для ветки '${BRANCH}' в репозитории '${REPO}'..."

response=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/${REPO}/actions/workflows/${WORKFLOW_FILE}/runs?branch=${BRANCH}&per_page=1")

conclusion=$(echo "$response" | jq -r '.workflow_runs[0].conclusion')

echo "Статус последнего запуска: $conclusion"
if [ "$conclusion" != "success" ]; then
  echo "Lint workflow не прошёл успешно. Деплой прерван."
  exit 1
fi