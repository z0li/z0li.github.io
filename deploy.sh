#!/bin/bash

echo "* checking out the master branch:"
git clone --single-branch --branch master git@github.com:z0li/z0li.github.io.git master

echo "* synchronizing the files:"
rsync -arv public/ master --delete --exclude ".git"
cp README.md master/

echo "* pushing to master:"
git add -A
git commit -m "Automated deplyoment job ${CIRCLE_BRANCH} #${CIRCLE_BUILD_NUM} [skip ci]" --allow-empty
git push origin master

echo "* done"
