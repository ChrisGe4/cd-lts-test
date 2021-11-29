#!/bin/bash

TITLE_OS="LTS image has OS vulnerability!"
OS_VULN_FILE=/workspace/os_vuln.txt

# TODO: change to real label
if [ -z "$_OS_VULN_LABEL" ]; then
  _OS_VULN_LABEL="lts os vuln"
fi
# TODO: change to skaffold repo
if [ -z "$_REPO" ]; then
  _REPO="ChrisGe4/cd-lts-test"
fi
check_existing_issue() {
  label=$1

  if [ $(gh issue list --label="$label" --repo="$_REPO" | wc -c) -ne 0 ]; then
    echo "There is already an issue opened for the detected vulnerabilities in the LTS images." && exit 0
  fi
}

create_issue() {
  title="$1"
  body_file="$2"
  label="$3"
#  echo gh issue create --title="$title" --label="$label" --body-file="$body_file" --body="Vulnerabilities have been found in the following images:" --repo="ChrisGe4/cd-lts-test"
  gh issue create --title="${title}" --label="${label}" --body "$(cat "$body_file")" --repo="$_REPO"
  #  --body="Vulnerabilities have been found in the following images:"
}

gh auth login --with-token < token.txt
check_existing_issue "$_OS_VULN_LABEL"
echo "creating an issue"
create_issue "$TITLE_OS" "$OS_VULN_FILE" "$_OS_VULN_LABEL"
