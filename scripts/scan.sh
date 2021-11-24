#!/bin/bash
set -e

PROJECT_ID=cd-demo-01
BASE_IMAGE="us-east1-docker.pkg.dev/$PROJECT_ID/lts-demo/"
OS_VULN_FILE=/workspace/os_vuln.txt
GREP_TEMPLATE="-e "
IMAGES="github:latest"
append() {
  printf "%s\n" $1 >>$2
}
if [ -z "$_SEVERITIES" ]; then
  _SEVERITIES="HIGH CRITICAL"
fi
grep_args=""
for s in $_SEVERITIES; do
  grep_args="$grep_args $GREP_TEMPLATE $s"
done
echo grep_args = $grep_args
echo project id = $PROJECT_ID

grep_cmd="grep $grep_args"
echo "${grep_cmd[@]}"
#echo "" > $OS_VULN_FILE
for ima in $IMAGES; do
  image=$BASE_IMAGE$ima
  echo ">>>checking vulnerabilities of image:" $image
  gcloud artifacts docker images describe $image \
    --show-package-vulnerability | if eval "$grep_cmd"; then append $ima $OS_VULN_FILE; fi

done
