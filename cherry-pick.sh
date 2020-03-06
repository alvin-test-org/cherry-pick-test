#!/bin/bash

# search for the PR labels applicable to the specified commit
resp=$(curl -f -s "https://api.github.com/search/issues?q=repo:$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME+sha:$CIRCLE_SHA1")
status="$?"
echo status is "$status"
if [[ "$status" -ne 0 ]]; then
  echo "This commit was not found in the GitHub API or was not associated with a PR"
  exit $status
fi

labels=$(echo "$resp" | jq --raw-output '.items[].labels[] | .name')

for label in $labels; do
    git config --local user.email "hashicorp-ci@users.noreply.github.com"
    git config --local user.name "hashicorp-ci"
    echo "checking label: $label"
    if [[ $label =~ docs* ]]; then
        echo "docs"
        git checkout stable-website
        git cherry-pick $CIRCLE_SHA1
        git push origin stable-website
    elif [[ $label =~ backport/* ]]; then
        echo "backporting to $label"
        branch=${label/backport/release}
        git checkout $branch
        git cherry-pick $CIRCLE_SHA1
        git push origin $branch
    fi
done
