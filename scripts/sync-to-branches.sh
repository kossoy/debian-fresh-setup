#!/bin/bash

# Helper script that can be used to sync one or more files from the 'master'
# branch across a number of branches that are given as parameters.

# PREREQUISITES:
# 1. 'git' installed and able to pull/push changes to https://github.company.com/
# 2. 'gh' installed and authenticated using 'gh auth login --hostname github.company.com'
#     https://cli.github.com/manual/gh_auth_login

# USAGE:
# 1. Update 'namespace.yaml' or any other file defined by FILES_TO_SYNC and merge to 'master'.
# 2. Run this script and provide 'target_*' branches as space separated parameters
# 3. Script will sync 'namespace.yaml' to each branch and open a PR
# 4. Go to github and merge the PRs

# EXAMPLE: ./sync_to_branches.sh target_front-v3_parpr1 target_front-v3_amsdr1

# TESTED WITH:
# git version 2.37.2
# gh version 2.14.4 (2022-08-10)

set -eu

SOURCE_BRANCH="master"
FILES_TO_SYNC="namespace.yaml"
TARGET_BRANCHES=$@

function print_yellow() {
    printf "\e[1;33m$*\e[0m"
}

function print_green() {
    printf "\e[1;32m$*\e[0m"
}

function print_blue() {
    printf "\e[1;34m$*\e[0m"
}

function branch_exists() {
    BRANCH=$1
    if [ -n "$(git ls-remote --heads origin $BRANCH)" ];then
        return 0
    else
        return 1
    fi
}

function random_suffix() {
    echo $(date | md5 | head -c 8)
}

function update_source_branch() {
    print_blue "### Update $SOURCE_BRANCH ###\n"
    if branch_exists $SOURCE_BRANCH;then
        git checkout $SOURCE_BRANCH
        git pull
    else
        print_yellow "ERROR: "
        echo "Branch '$SOURCE_BRANCH' not found. Use a different SOURCE_BRANCH."
        exit 1
    fi
}

function sync_to_branch() {
    BRANCH=$1
    TEMP_BRANCH="temp_${BRANCH}-$(random_suffix)"
    COMMIT_MSG="Sync $FILES_TO_SYNC from $SOURCE_BRANCH to $BRANCH"
    print_green "=== TARGET BRANCH: $BRANCH ===\n"
    if branch_exists "$BRANCH";then
        print_green "SYNC FILES:\n"
        git checkout -b "$TEMP_BRANCH" "origin/$BRANCH"
        git checkout "$SOURCE_BRANCH" "$FILES_TO_SYNC"
        git commit -m "$COMMIT_MSG"
        git push -u origin "$TEMP_BRANCH"

        print_green "CREATE PR:\n"
        gh pr create \
            --title="$COMMIT_MSG" \
            --body "$COMMIT_MSG" \
            --base "$BRANCH" \
            --head "$TEMP_BRANCH"
    else
        print_yellow "ERROR: "
        echo "Branch '$BRANCH' not found. Specify a different target branch."
    fi
}

function sync_to_target_branches() {
    print_blue "### Sync files to target branches ###\n"
    for b in $TARGET_BRANCHES;do
        sync_to_branch $b
    done
}

update_source_branch

sync_to_target_branches
