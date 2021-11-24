#!/bin/bash
set -e

if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=cd-demo-01
fi
#if [ -z "$_REPO" ]; then
#  _REPO="lts-demo"
#fi
if [ -z "$_LOCATION" ]; then
  _LOCATION="us-east1"
fi
if [ -z "$_IMAGE" ]; then
  _IMAGE="github"
fi
if [ -z "$_BASE_IMAGE" ]; then
#  _BASE_IMAGE="$_LOCATION-docker.pkg.dev/$PROJECT_ID/$_REPO/"
  _BASE_IMAGE="gcr.io/$PROJECT_ID/$_IMAGE"
fi
OS_VULN_FILE=/workspace/os_vuln.txt
GREP_TEMPLATE="-e "
_TAGS="latest"
append() {
  printf "%s\n" $1 >>$2
}
if [ -z "$_TAGS" ]; then
# Get the last 5 images if _TAGS not set
_TAGS=$(gcloud container images list-tags $_BASE_IMAGE --filter="tags:v*lts" --limit=5)
fi

if [ -z "$_SEVERITIES" ]; then
  _SEVERITIES="HIGH CRITICAL"
fi
grep_args=""
for s in $_SEVERITIES; do
  grep_args="$grep_args $GREP_TEMPLATE $s"
done
echo project id = $PROJECT_ID

grep_cmd="grep $grep_args"
echo "${grep_cmd[@]}"
#echo "" > $OS_VULN_FILE
for tag in $_TAGS; do
  image=$_BASE_IMAGE:$tag
  echo ">>>checking vulnerabilities of image:" $image
#  gcloud artifacts docker images describe $image \
#    --show-package-vulnerability
    gcloud beta container images describe $image \
    --show-package-vulnerability | if eval "$grep_cmd"; then append $tag $OS_VULN_FILE; fi

done
