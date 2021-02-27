#!/bin/bash

set -e

TARGET=$1

if [[ -z $TARGET ]]; then
  echo "! missing [target] argument"
  echo "usage: ./migrate.sh <git-clone-ssh-url>"
  exit 1
fi

if [[ -z $USER ]]; then
  echo "! missing USER env var, github username"
  exit 1
fi

if [[ -z $TOKEN ]]; then
  echo "! missing TOKEN env var, github user access token"
  exit 1
fi

REGEX="\/(.*)\.git$"
[[ $TARGET =~ $REGEX ]]
NAME="${BASH_REMATCH[1]}"
echo
echo "repo => $NAME"
echo

if [[ -d "./$NAME" ]]; then
  echo "skipping cloning, repo already exists locally"
else
  # clone locally
  git clone $TARGET
fi

# create repo on github for user
BODY="{
  \"name\": \"$NAME\",
  \"private\": true,
  \"has_issues\": false,
  \"has_projects\": false,
  \"has_wiki\": false,
  \"auto_init\": false,
  \"allow_merge_commit\": false,
  \"allow_rebase_merge\": false,
  \"delete_branch_on_merge\": true
}"

RESPONSE=$(curl \
  -o /dev/null \
  -w "%{http_code}" \
  -u username:$TOKEN \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "$BODY")

echo $RESPONSE
if [[ $RESPONSE == "201" ]]; then
  echo "repo created '$NAME' ..."
elif [[ $RESPONSE == "422" ]]; then
  echo "repo already exists '$NAME', using existing ..."
else
  echo "! failed to create '$NAME'"
  exit 1
fi

ROOT=$PWD
cd ./$NAME

# mask personal email
if [[ -e "../mailmap" ]]; then
  ../git-filter-repo --mailmap ../mailmap --force
else
  echo "skipping masking, no mailmap found"
fi

# remove possible old origin
git remote remove origin || true
# new origin to push to
git remote add origin git@github.com:$USER/$NAME.git
git push --all origin

cd $ROOT

# cleanup
rm -rf ./$NAME
