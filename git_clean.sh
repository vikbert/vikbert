#!/usr/bin/env bash
source printing.sh

PRIMARY_BRANCH='main'
DRY_RUN=false

switch_branch() {
  PRIMARY_BRANCH="$1"
  #git stash
  git checkout $PRIMARY_BRANCH
  print_success "Swithc to the primary branch $PRIMARY_BRANCH"
}

select_primary_branch() {
    read -p "Which one is your ${bold}primary${normal} branch 1) main 2) master, 3) develop, Enter the number 1 2 or 3 ? " selection
    print_hr
    case $selection in
        [1]* ) switch_branch "main";;
        [2]* ) switch_branch "master";;
        [3]* ) switch_branch "develop";;
        * ) print_error "Please answer 1 or 2.";;
    esac
}

___detect_primary_branch_switched() {
  present_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [ "$present_branch" != "main" ]; then
  print_error "You are on branch '$present_branch', please switch to your primary branch: main | master";
  exit;
  fi
}

start_script() {
  if [ "$DRY_RUN" == true ]; then
    print_warning "DryRun mode is enabled and nothing will be deleted in dry-run mode!"
  fi
  select_primary_branch
}

if [ "$1" == "--dry-run" ]; then
  DRY_RUN=true
  start_script
else
  DRY_RUN=false
  start_script
fi


print_info "Fetching merged branches..."
git remote prune origin
remote_branches=$(git branch -r --merged | grep -v "/$PRIMARY_BRANCH$")
local_branches=$(git branch --merged | grep -v "$PRIMARY_BRANCH$")
if [ -z "$remote_branches" ] && [ -z "$local_branches" ]; then
  print_warning "No existing branches have been merged into $PRIMARY_BRANCH."
else
  print_info "This will remove the following branches:"
  print_hr
  if [ -n "$remote_branches" ]; then
    echo "$remote_branches"
  fi
  if [ -n "$local_branches" ]; then
    echo "$local_branches"
  fi
  print_hr
  print_warning "master, main and develop will not be deleted"
  read -p "Delete? (y/n): " -n 1 selection
  echo
  if [ "$selection" == "y" ] || [ "$selection" == "Y" ]; then
    # delete remote branches
    # git push origin `git branch -r --merged | grep -v '/main$' | grep -v "/$present_branch$" | grep -v "develop" |grep -v "staging"|sed 's/origin\//:/g' | tr -d '\n'`

    # delete local branches
    #git branch -d `git branch --merged | grep -v 'main$' | grep -v "develop" | grep -v "staging" | grep -v "$present_branch$" | sed 's/origin\///g' | tr -d '\n'`
    print_green 'deleting local branch'

  else
    echo "No Branches Were deleted."
  fi
fi
