#!/bin/bash

PULL_SECRET_FILE=$(HOME)/pull-secret.txt

# curl --output prefetch-dependencies.yaml https://raw.githubusercontent.com/konflux-ci/build-definitions/refs/heads/main/task/prefetch-dependencies/0.2/prefetch-dependencies.yaml

crc config set memory 16384
crc config set cpus 8
crc config set disk-size 64

crc setup
crc start --pull-secret-file "$PULL_SECRET_FILE"

curl https://storage.googleapis.com/tekton-releases/pipeline/latest/release.notags.yaml | yq 'del(.spec.template.spec.containers[].securityContext.runAsUser, .spec.template.spec.containers[].securityContext.runAsGroup)' | oc apply -f -

oc get pods --namespace tekton-pipelines --watch

oc apply -f prefetch-dependencies.yaml
oc apply -f docker-build.yaml
oc apply -f docker-build-run.yaml
