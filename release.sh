#!/bin/sh

branch="$(git branch --show-current)"
if [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
  echo "Error: Releases must be created from trunk, run $0 in main/master."
  exit 1
fi

if [ -n "$(git status -s)" ]; then
  echo "Error: Working tree has changes: Stash, commit or reset first"
  exit 1
fi

pipx run --spec commitizen cz bump --changelog
