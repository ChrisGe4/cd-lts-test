#!/bin/bash
#set -e

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
append() {
  printf "%s\n" $1 >>$2
}
if [ -z "$_SEVERITIES" ]; then
  _SEVERITIES="HIGH CRITICAL"
fi

check_vulnerability(){

# base image
base_image=$1
echo $base_image
tags_filter=$2
echo $tags_filter

severities=$3
result_file=$4
echo $result_file

tags=$5
echo $tags
if [ -z "$tags" ]; then
# Get the last 5 images if _TAGS not set
echo gcloud container images list-tags "$base_image" --filter="tags:$tags_filter" --limit=5 --format='value(tags)'
tags=$(gcloud container images list-tags "$base_image" --filter="tags:$tags_filter" --limit=5 --format='value(tags)')
fi
grep_args=""
for s in $severities; do
  grep_args="$grep_args $GREP_TEMPLATE $s"
done

grep_cmd="grep $grep_args"
echo "${grep_cmd[@]}"
for tag in $tags; do
  image=$base_image:$tag
  echo ">>>checking vulnerabilities of image:" $image
#  gcloud artifacts docker images describe $image \
#    --show-package-vulnerability
    gcloud beta container images describe $image \
    --show-package-vulnerability | if eval "$grep_cmd"; then append $tag $result_file; fi
done
}

echo project id = $PROJECT_ID

# check LTS image
check_vulnerability $_BASE_IMAGE "v*lts" "$_SEVERITIES" "$OS_VULN_FILE" "$_TAGS"





#if [ -z "$_TAGS" ]; then
## Get the last 5 images if _TAGS not set
#_TAGS=$(gcloud container images list-tags $_BASE_IMAGE --filter="tags:v*lts" --limit=5)
#fi
#grep_args=""
#for s in $_SEVERITIES; do
#  grep_args="$grep_args $GREP_TEMPLATE $s"
#done
#
#grep_cmd="grep $grep_args"
#echo "${grep_cmd[@]}"
##echo "" > $OS_VULN_FILE
#for tag in $_TAGS; do
#  image=$_BASE_IMAGE:$tag
#  echo ">>>checking vulnerabilities of image:" $image
##  gcloud artifacts docker images describe $image \
##    --show-package-vulnerability
#    gcloud beta container images describe $image \
#    --show-package-vulnerability | if eval "$grep_cmd"; then append $tag $OS_VULN_FILE; fi
#done
