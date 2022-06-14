#!/bin/bash
set -x

if [[ $(gh pr list) ]]; then
  echo "PR open listed. Notify to update"
  gh pr list | awk '{print$1}' | while read -r line; do
    gh pr review $line --request-changes --body "The HEAD branch was updated!!! \
      I'll merge the updates into your branch, so make sure you test and/or resolve conflicts. \
      I'm requesting a review at this very moment, and I'll approve when this branch first deploy \
      into staging!"
  done
else
  echo "Noting to do, No PR found, done!"
fi
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
MY_CUSTOM_CONDITION=$(git branch -a | grep "origin" | grep -vE "main|master|HEAD|${CURRENT_BRANCH}" | grep -Eo "release.*|hotfix.*")
if [[ ! -n "${MY_CUSTOM_CONDITION}" ]]; then
  git branch -a | grep "origin" | grep -vE "main|master|HEAD|${CURRENT_BRANCH}" | grep -Eo "release.*|hotfix.*" | while read -r line; do
    echo ">>>CURRENT-LINE: ${line}"
    git checkout $line
    git merge -X theirs origin/main
    git push --force
  done
else
  echo "No release and hotfix to update!"
fi
