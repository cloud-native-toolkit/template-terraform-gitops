#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

export KUBECONFIG="${SCRIPT_DIR}/.kube/config"

CLUSTER_TYPE="$1"
NAMESPACE="$2"
NAME="$3"

if [[ -z "${NAME}" ]]; then
  NAME=$(echo "${NAMESPACE}" | sed "s/tools-//")
fi

echo "Verifying resources in ${NAMESPACE} namespace for module ${NAME}"

PODS=$(kubectl get -n "${NAMESPACE}" pods -o jsonpath='{range .items[*]}{.status.phase}{": "}{.kind}{"/"}{.metadata.name}{"\n"}{end}' | grep -v "Running" | grep -v "Succeeded")
POD_STATUSES=$(echo "${PODS}" | sed -E "s/(.*):.*/\1/g")
if [[ -n "${POD_STATUSES}" ]]; then
  echo "  Pods have non-success statuses: ${PODS}"
  exit 1
fi

set -e

if [[ "${CLUSTER_TYPE}" == "kubernetes" ]] || [[ "${CLUSTER_TYPE}" =~ iks.* ]]; then
  ENDPOINTS=$(kubectl get ingress -n "${NAMESPACE}" -o jsonpath='{range .items[*]}{range .spec.rules[*]}{"https://"}{.host}{"\n"}{end}{end}')
else
  ENDPOINTS=$(kubectl get route -n "${NAMESPACE}" -o jsonpath='{range .items[*]}{"https://"}{.spec.host}{.spec.path}{"\n"}{end}')
fi

echo "Validating endpoints:\n${ENDPOINTS}"

echo "${ENDPOINTS}" | while read endpoint; do
  if [[ -n "${endpoint}" ]]; then
    ${SCRIPT_DIR}/waitForEndpoint.sh "${endpoint}" 10 10
  fi
done

CONFIG_URLS=$(kubectl get configmap -n "${NAMESPACE}" -l grouping=garage-cloud-native-toolkit -l app.kubernetes.io/component=tools -o json | jq '.items[].data | to_entries | select(.[].key | endswith("_URL")) | .[].value' | sed "s/\"//g")

echo "${CONFIG_URLS}" | while read url; do
  if [[ -n "${url}" ]]; then
    ${SCRIPT_DIR}/waitForEndpoint.sh "${url}" 10 10
  fi
done

if [[ "${CLUSTER_TYPE}" == "ocp4" ]]; then
  echo "Validating consolelink"
  if [[ $(kubectl get consolelink "toolkit-${NAME}" | wc -l) -eq 0 ]]; then
    echo "   ConsoleLink not found"
    exit 1
  fi
fi

exit 0
