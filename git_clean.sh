#!/usr/bin/env bash
source printing.sh

PRIMARY_BRANCH='main'

switch_branch() {
  target="$1"
  git checkout $target
  print_success "Swithc to the primary branch $target"
}

select_primary_branch() {
    read -p "Do you wish to switch to the ${bold}primary${normal} branch (1-main 2-master, 1 or 2)?" selection
    print_hr
    case $selection in
        [1]* ) switch_branch "main";;
        [2]* ) switch_branch "master";;
        * ) print_error "Please answer 1 or 2.";;
    esac
}

detect_primary_branch_switched() {
  present_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [ "$present_branch" != "main" ]; then
  print_error "You are on branch '$present_branch', please switch to your primary branch: main | master";
  exit;
  fi
}

select_primary_branch

#------- detect current active branch name


echo "Fetching merged branches..."
git remote prune origin
remote_branches=$(git branch -r --merged | grep -v '/main$' | grep -v "/$present_branch$")
local_branches=$(git branch --merged | grep -v 'main$' | grep -v "$present_branch$")
if [ -z "$remote_branches" ] && [ -z "$local_branches" ]; then
  echo "No existing branches have been merged into $present_branch."
else
  echo "This will remove the following branches:"
  if [ -n "$remote_branches" ]; then
    echo "$remote_branches"
  fi
  if [ -n "$local_branches" ]; then
    echo "$local_branches"
  fi
  echo "====================="
  echo "staging & develop will not be deleted"
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
