#!/bin/bash

# Initializes Nginx and the git cgi scripts
# for git http-backend through fcgiwrap.
#
# Usage:
#   entrypoint <commands>
#
# Commands:
#   -start    starts the git server (nginx + fcgi)
#
#   -init     turns directories under `/var/lib/initial`
#             into bare repositories at `/var/lib/git`
#

set -e

readonly GIT_PROJECT_ROOT="/home/git"
readonly GIT_INITIAL_ROOT="/var/lib/initial"
readonly GIT_HTTP_EXPORT_ALL="true"
readonly GIT_USER="git"
readonly GIT_GROUP="git"

readonly SOCKUSERID="$USERID"

main() {
  mkdir -p $GIT_PROJECT_ROOT


  # Checks if $GIT_INITIAL_ROOT has files
  if [[ $(ls -A ${GIT_INITIAL_ROOT}) ]]; then
    initialize_initial_repositories
  fi
  initialize_services

  echo "Running: $@"
  exec "$@"
}

initialize_services() {
  # Check permissions on $GIT_PROJECT_ROOT
  if [[ ! $(stat -c %A ${GIT_PROJECT_ROOT}) -eq "drwxr-xr-x" ]]; then
    chown -R git:git $GIT_PROJECT_ROOT
    chmod -R 775 $GIT_PROJECT_ROOT
  fi
}

initialize_initial_repositories() {
  cd $GIT_INITIAL_ROOT
  for dir in $(find . -name "*" -type d -maxdepth 1 -mindepth 1); do
    echo "Initializing repository $dir"
    init_and_commit $dir
  done
}

init_and_commit() {
  local dir=$1
  local tmp_dir=$(mktemp -d)

  cp -r $dir/* $tmp_dir
  pushd . >/dev/null
  cd $tmp_dir

  if [[ -d "./.git" ]]; then
    rm -rf ./.git
  fi

  git init &>/dev/null
  git add --all . &>/dev/null
  git commit -m "first commit" &>/dev/null
  git clone --bare $tmp_dir $GIT_PROJECT_ROOT/${dir}.git &>/dev/null

  popd >/dev/null
}

main "$@"
