#!/bin/bash

source ./ci/functions.sh

CAS_VERSION=${1:-$DEFAULT_CAS_VERSION}
BOOT_VERSION=${2:-$DEFAULT_BOOT_VERSION}
BRANCH=${3:-master}

java -jar app/build/libs/app.jar &
pid=$!
sleep 15
mkdir tmp
cd tmp

echo "Building CAS overlay ${CAS_VERSION} with Spring Boot ${BOOT_VERSION} for branch ${BRANCH}"
curl http://localhost:8080/starter.tgz \
  -d baseDir=initializr \
  -d "casVersion=${CAS_VERSION}&bootVersion=${BOOT_VERSION}" | tar -xzvf -
kill -9 $pid

echo "Cloning CAS overlay repository..."
git clone --depth 1 https://${GH_TOKEN}@github.com/apereo/cas-overlay-template $PWD/overlay-repo

echo "Moving .git directory into generated overlay"
mv $PWD/overlay-repo/.git ./initializr
rm -Rf $PWD/overlay-repo

echo "Configuring git..."
cd ./initializr && pwd
git config user.email "cas@apereo.org"
git config user.name "CAS"

echo "Checking repository status..."
git status

echo "Committing changes..."
git add --all
git commit -am "Sync"
git status

echo "Pushing changes to branch ${BRANCH}"
git push --set-upstream origin ${BRANCH}

echo "Done"

exit 1