#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

REPO="$1"
REPO_PATH="$2"
PROJECT="$3"
APPLICATION_REPO="$4"
APPLICATION_GIT_PATH="$5"
NAMESPACE="$6"
BRANCH="$7"

REPO_DIR=".tmprepo-dashboard-${NAMESPACE}"

SEMAPHORE="${REPO//\//-}.semaphore"
SEMAPHORE_ID="${SCRIPT_DIR//\//-}"

while true; do
  echo "Checking for semaphore"
  if [[ ! -f "${SEMAPHORE}" ]]; then
    echo -n "${SEMAPHORE_ID}" > "${SEMAPHORE}"

    if [[ $(cat "${SEMAPHORE}") == "${SEMAPHORE_ID}" ]]; then
      echo "Got the semaphore. Setting up gitops repo"
      break
    fi
  fi

  SLEEP_TIME=$((1 + $RANDOM % 10))
  echo "  Waiting $SLEEP_TIME seconds for semaphore"
  sleep $SLEEP_TIME
done

function finish {
  rm "${SEMAPHORE}"
}

trap finish EXIT

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

cat > "${REPO_PATH}/dashboard.yaml" <<EOL
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: dashboard-${BRANCH}
spec:
  destination:
    namespace: ${NAMESPACE}
    server: "https://kubernetes.default.svc"
  project: ${PROJECT}
  source:
    path: ${APPLICATION_GIT_PATH}
    repoURL: https://${APPLICATION_REPO}
    targetRevision: ${BRANCH}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOL

if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  git add .
  git commit -m "Adds argocd config for dashboard"
  git push
fi

cd ..
rm -rf "${REPO_DIR}"
