#!/bin/bash

CONFIG=""

# check if a custom config have been provided
if [ -f "$GITHUB_WORKSPACE/rules.toml" ]; then
  CONFIG=" --config-path=$GITHUB_WORKSPACE/rules.toml"
fi

echo running gitleaks "$(gitleaks --version) with the following command👇"

if [ "$GITHUB_EVENT_NAME" = "push" ]
then
  echo gitleaks --path=$GITHUB_WORKSPACE --verbose --redact $CONFIG
  CAPTURE_OUTPUT=$(gitleaks --path=$GITHUB_WORKSPACE --verbose --redact $CONFIG)
elif [ "$GITHUB_EVENT_NAME" = "pull_request" ]
then 
  git --git-dir="$GITHUB_WORKSPACE/.git" log --left-right --cherry-pick --pretty=format:"%H" remotes/origin/$GITHUB_BASE_REF...remotes/origin/$GITHUB_HEAD_REF > commit_list.txt
  echo gitleaks --path=$GITHUB_WORKSPACE --verbose --redact --commits-file=commit_list.txt $CONFIG
  CAPTURE_OUTPUT=$(gitleaks --path=$GITHUB_WORKSPACE --verbose --redact --commits-file=commit_list.txt $CONFIG)
fi

if [ $? -eq 1 ]
then
  GITLEAKS_RESULT=$(echo -e "\e[31m🛑 STOP! Gitleaks encountered leaks")
  echo "$GITLEAKS_RESULT"
  #echo "::set-output name=exitcode::$GITLEAKS_RESULT"
  echo "----------------------------------"
  echo "$CAPTURE_OUTPUT"
  #echo "::set-output name=result::$CAPTURE_OUTPUT"
  echo "----------------------------------"
  exit 1
else
  GITLEAKS_RESULT=$(echo -e "\e[32m✅ SUCCESS! Your code is good to go!")
  echo "$GITLEAKS_RESULT"
  #echo "::set-output name=exitcode::$GITLEAKS_RESULT"
  echo "------------------------------------"
fi
