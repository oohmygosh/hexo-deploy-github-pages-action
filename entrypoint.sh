#!/bin/sh -l

set -e

# check values

if [ -n "${PUBLISH_REPOSITORY}" ]; then
    TARGET_REPOSITORY=${PUBLISH_REPOSITORY}
else
    TARGET_REPOSITORY=${GITHUB_REPOSITORY}
fi

if [ -n "${BRANCH}" ]; then
    TARGET_BRANCH=${BRANCH}
else
    TARGET_BRANCH="gh-pages"
fi

if [ -n "${PUBLISH_DIR}" ]; then
    TARGET_PUBLISH_DIR=${PUBLISH_DIR}
else
    TARGET_PUBLISH_DIR="./public"
fi

if [ -z "$PERSONAL_TOKEN" ]
then
  echo "You must provide the action with either a Personal Access Token or the GitHub Token secret in order to deploy."
  exit 1
fi

REPOSITORY_PATH="https://x-access-token:${PERSONAL_TOKEN}@github.com/${TARGET_REPOSITORY}.git"

# deploy to
echo ">>>>> Start deploy to ${TARGET_REPOSITORY} <<<<<"

# Installs Git.
echo ">>> Install Git ..."
apt-get update && \
apt-get install -y git && \
# Directs the action to the the Github workspace.
cd "${GITHUB_WORKSPACE}"

echo ">>> Install NPM dependencies ..."
npm install

echo ">>> Clean folder ..."
npx hexo clean

echo ">>> Generate file ..."
npx hexo generate

cd $TARGET_PUBLISH_DIR

echo ">>> init CNAME"

echo "blog.vipicu.com" > CNAME


echo "Copy ${PUBLISH_REPOSITORY} img folder"

rm -rf img
mkdir temp
pwd
PUBLIC_PATH=`pwd`
cd temp
echo ">>>>>>>>>>>>>>"
pwd
ls
echo "<<<<<<<<<<<<<<"
# Configures Git.
git init
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

git config user.name "${GITHUB_ACTOR}"
git remote add origin "${REPOSITORY_PATH}"
git config core.sparsecheckout true
echo "/img" >> .git/info/sparse-checkout 
git pull origin $TARGET_BRANCH
mv ./img ../

cd ..
rm -rf temp
echo ">>>>>>>>>>>>>>"
pwd
ls
echo "<<<<<<<<<<<<<<"

echo "Copy completed"

echo ">>> Config git ..."
pwd
ls
git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git remote add origin "${REPOSITORY_PATH}"

git checkout --orphan $TARGET_BRANCH

git add .

echo '>>> Start Commit ...'
git commit --allow-empty -m "Building and deploying Hexo project from Github Action"

echo '>>> Start Push ...'
git push -u origin "${TARGET_BRANCH}" --force

echo ">>> Deployment successful!"
