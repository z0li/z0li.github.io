---
title: "Continuously deliver static sites with Hugo, CircleCI and GitHub Pages"
date: 2019-05-18T16:03:52+02:00
tags: ["howto", "tutorial", "hugo", "circleci", "docker", "github", "gh-pages", "ci/cd"]
---

In this tutorial you will learn how to use [Hugo](https://gohugo.io) and [CircleCI](https://circleci.com) to continuously deliver a static site to GitHub Pages.

## Prerequisites

- A Github account

## GitHub Pages

[Create a GitHub Pages repository](https://pages.github.com/) and clone it - the name of the respository must be `<username>.github.io`:

```
git clone git@github.com:<username>/<username>.github.io.git
```

## Hello Hugo

Follow the [official Hugo Quick Start guide](https://gohugo.io/getting-started/quick-start/) to setup Hugo on your machine and create some content inside the newly created repository.

Create a `.gitignore` file to ignore Hugo's build directories:

```
$ vim .gitignore 
/public
/resources
```

Push everything to a new branch named `development`:

```
git checkout -b development
git push -u origin development
```

## GitHub Deploy Key

[Register a new Deploy Key](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys) with write access to your repository. This will be needed for CircleCI to be able to publish the content.

## CircleCI

We will use CircleCI to monitor our newly created `development` branch and run Hugo inside a Docker container after each commit. Finally, we will publish the content of the `public` directory to the `master` of our repository.

1. [Sign up to CircleCI](https://circleci.com/signup/) using your GitHub account

2. And [add your repository](https://circleci.com/add-projects) as a CircleCI project

3. [Set up your new Deploy Key in CircleCI](https://circleci.com/docs/2.0/add-ssh-key/)

### CircleCI build configuration

Create a `.circleci\config.yml` for the CircleCI configuration:

```
$ vim .circleci\config.yml
```

In the configuration first we have to define the Docker image needed for the build. For this we will use [z0li/hugo-builder](https://hub.docker.com/r/z0li/hugo-builder):

```
version: 2
jobs:
  build:
    docker:
      - image: z0li/hugo-builder:latest
```

Next we define a working directory and the build steps:

```
    working_directory: /src
    steps:
```

Instruct CircleCI to use your Deploy Key:

```    
    steps:
      - add_ssh_keys:
          fingerprints:
            - "<your_deploy_key_fingerprint>"
```

Note: make sure to replace `<your_deploy_key_fingerprint>` with the actual fingerprint of your own key.

Checkout your code and setup the git submodule containing the Hugo theme:

```
    steps:
      - checkout
      - run: git submodule update --init
```

Run Hugo to generate the static content:

```
      - run: hugo -v -s /src -d /src/public
```

The Docker image comes with [htmlproofer](https://github.com/gjtorikian/html-proofer), we will use it to verify our html files:

```
      - run:
          name: test the generated html files
          command: htmlproofer /src/public --allow-hash-href --check-html --empty-alt-ignore --disable-external
```

Create a `deploy.sh` that will contain the commands for pushing the changes back to the `master` of your repository:

```
#!/bin/bash
set -e

echo "* checking out the master branch:"
git clone --single-branch --branch master git@github.com:z0li/z0li.github.io.git master

echo "* synchronizing the files:"
rsync -arv public/ master --delete --exclude ".git"
cp README.md master/

echo "* pushing to master:"
cd master
git config user.name "CircleCI"
git config user.email ${GIT_EMAIL}
git add -A
git commit -m "Automated deployment job ${CIRCLE_BRANCH} #${CIRCLE_BUILD_NUM} [skip ci]" --allow-empty
git push origin master

echo "* done"
```

Execute this script as the final build step:

```
      - deploy:
          name: push to master branch
          command: sh deploy.sh
```

### config.yml

Your `config.yml` should look like this:

```
version: 2
jobs:
  build:
    docker:
      - image: z0li/hugo-builder:latest
    working_directory: /src
    steps:
      - add_ssh_keys:
          fingerprints:
            - "<your_deploy_key_fingerprint>"
      - checkout
      - run: git submodule update --init
      - run: hugo -v -s /src -d /src/public
      - run:
          name: test the generated html files
          command: htmlproofer /src/public --allow-hash-href --check-html --empty-alt-ignore --disable-external
      - deploy:
          name: push to master branch
          command: sh deploy.sh
```

## Finally

Push your `.circleci\config.yml` to the `development` branch and it should trigger a new build and deployment. Visit `https://<username>.github.io` to see the end result.
