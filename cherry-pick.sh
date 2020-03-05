#!/bin/bash

# search for the PR labels applicable to the specified commit
labels=$(curl "https://api.github.com/search/issues?q=repo:$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME+sha:$CIRCLE_SHA1" | --raw-output '.items[].labels[] | .name')

for label in $labels; do
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
