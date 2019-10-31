#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset

# set -o xtrace
# Set magic variables for current file & dir

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

spin() {

    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null
    do
        i=$(( (i+1) %4 ))
        printf "\r${spin:$i:1}"
        sleep .1
    done
}

REMOTE="${1:-}"

if [[ -z "${REMOTE}" ]]
then
    echo "";
    echo "      Usage: migraterepo.sh new_repo_url";
    echo "";
    exit 1;
fi

# snippet to easily migrate a repo
echo 'Fetching origin';
git fetch origin 2>/dev/null & pid=$!
spin;
printf "\rdone\n\n";
echo 'Adding the new remote as new_origin';
git remote add new_origin ${REMOTE} 2>/dev/null & pid=$!
spin;
printf "\rdone\n\n";
echo 'Iterating all the branches and setting to track the remote';
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done 2>/dev/null & pid=$!
spin;
printf "\rdone\n\n";
echo "Iterating through all the branches and pushing to the new remote"
git branch -r | grep -v '\->' | while read remote; do git checkout "${remote#origin/}" && git push new_origin "${remote#origin/}"; done 2>/dev/null & pid=$!
spin;
printf "\rdone\n\n";
echo "Removing remote 'origin' and renaming 'new_origin' to 'origin'";
git remote remove origin 2>/dev/null & pid=$!
spin;
git remote rename new_origin origin 2>/dev/null & pid=$!
spin;
printf "\rdone\n";
exit 0;
