#!/usr/bin/env bash
set -euo pipefail
set -x

GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
BUILD_DIR="${GIT_REPO_ROOT}/build"
TOOLS_DIR="${BUILD_DIR}/tools"
STABLE="${GIT_REPO_ROOT}/stable"
PACKAGE_DIR="${GIT_REPO_ROOT}/build"
export PATH="${TOOLS_DIR}:${PATH}"
VERSION="$(git describe --tags --always)"

if echo "${VERSION}" | grep -Eq "^v[0-9]+(\.[0-9]+){2}$"; then
    git fetch --all
    git config user.email eks-bot@users.noreply.github.com
    git config user.name eks-bot
    git remote set-url origin https://github.com/jaydeokar/eks-charts.git 
    git config pull.rebase false
    git checkout gh-pages
    mv -n $PACKAGE_DIR/stable/*.tgz .
    helm repo index . --url https://aws.github.io/eks-charts
    git add .
    git commit -m "Publish stable charts ${VERSION}"
    git push origin gh-pages
    echo "✅ Published charts"
else
    echo "Not a valid semver release tag! Skip charts publish"
    exit 1
fi

