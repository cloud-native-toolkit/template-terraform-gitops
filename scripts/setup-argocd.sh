#!/usr/bin/env bash

NAME="$1"
REPO="$2"
REPO_PATH="$3"
PROJECT="$4"
APPLICATION_REPO="$5"
APPLICATION_GIT_PATH="$6"
NAMESPACE="$7"
BRANCH="$8"

REPO_DIR=".tmprepo-argocd-${NAMESPACE}"

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

cat > "${REPO_PATH}/${NAME}.yaml" <<EOL
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${NAME}-${BRANCH}
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
  git commit -m "Adds argocd config for ${NAME}"
  git push
fi

cd ..
rm -rf "${REPO_DIR}"
