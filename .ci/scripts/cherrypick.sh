#!/bin/bash

# WARNING: DO NOT EDIT!
#
# This file was generated by plugin_template, and is managed by it. Please use
# './plugin-template --github pulp_npm' to update this file.
#
# For more info visit https://github.com/pulp/plugin_template

set -e

if [ $# -lt 3 ]
then
  echo "Usage: .ci/scripts/cherrypick.sh [commit-hash] [original-issue-id] [backport-issue-id]"
  echo "   ex: .ci/scripts/cherrypick.sh abcd1234 1234 4567"
  echo ""
  echo "Note: make sure you are on a fork of the release branch before running this script."
  exit
fi

commit="$(git rev-parse $1)"
issue="$2"
backport="$3"
commit_message=$(git log --format=%B -n 1 $commit)

if ! echo $commit_message | grep -q "\[noissue\]"
then
  if ! echo $commit_message | grep -q -E "(fixes|closes).*#$issue"
  then
    echo "Error: issue $issue not detected in commit message." && exit 1
  fi
fi

if [ "$4" = "--continue" ]
then
  echo "Continue after manually resolving conflicts..."
elif [ "$4" = "" ]
then
  if ! git cherry-pick --no-commit "$commit"
  then
    echo "Please resolve and add merge conflicts and restart this command with appended '--continue'."
    exit 1
  fi
else
  exit 1
fi

for file in $(find CHANGES -name "$issue.*")
do
  newfile="${file/$issue/$backport}"
  git mv "$file" "$newfile"
  sed -i -e "\$a (backported from #$issue)" "$newfile"
  git add "$newfile"
done

commit_message="$(printf "$commit_message" | sed -E 's/(fixes|closes)/backports/')"
commit_message="$commit_message

fixes #$backport

(cherry picked from commit $commit)"
git commit -m "$commit_message"

printf "\nSuccessfully backported commit $1.\n"
