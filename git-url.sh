#!/usr/bin/env bash

BLACK="\033[0;30m" RED="\033[0;31m" GREEN="\033[0;32m" YELLOW="\033[0;33m" BLUE="\033[0;34m" PURPLE="\033[0;35m" LIGHT_BLUE="\033[0;36m" WHITE="\033[0;37m" GRAY="\033[0;39m" DEFAULT="\033[0m"
function echo() { command echo -e "$@"; }

function main() {
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		echo "${RED}no git repo here!${DEFAULT}" >&2
		return 1
	fi

	local url=$(git config remote.origin.url)
	[[ -z $url ]] && echo "$0 [filepath] [line no]" && return 1
	local filepath=$1
	[[ -n $filepath ]] && local filepath=$(git ls-files --full-name $filepath)
	local lineno=$2

	local ret=$(echo $url | sed -E 's@^[a-z]+://@@' | sed -E 's:^[a-zA-z._0-9]+@::' | sed -E 's:\.git$::')
	local host_repo=$(echo $ret | sed -E 's@^([^:/]*)((:[0-9]+)/|:([^/]+/)|/)(.*)$@\1 \4\5@')
	local host=$(echo $host_repo | awk '{print$1}')
	local repo=$(echo $host_repo | awk '{print$2}')
	[[ -z $host ]] && echo "$0 parse error $ret" && return 1

	# NOTE: setting file ~/.ssh/config
	local web_url=$(ssh -G $host 2>/dev/null | grep -A 1 WEB_URL | grep -v WEB_URL | awk '{print $2}')
	[[ -z $web_url ]] && local web_url=$host
	local web_type='gerrit'
	echo $web_url | grep -q github && local web_type='github'
	echo $web_url | grep -q gitlab && local web_type='gitlab'

	local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "master")
	# NOTE: if local branch -> set master branch (default)
	git show-ref --quiet --verify -- "refs/remotes/origin/$branch" || local branch="master"
	local object='blob'
	local gerrit_f=";f=$filepath"
	# NOTE: no file
	if [[ -z $filepath ]]; then
		local gerrit_f=""
		local object='tree'
	fi
	local web_link="$web_url/gitweb?p=$repo.git$gerrit_f;hb=refs/heads/$branch#l$lineno"
	[[ $web_type == "github" ]] && local web_link="$web_url/$repo/$object/$branch/$filepath#L$lineno"
	[[ $web_type == "gitlab" ]] && local web_link="$web_url/$repo/blob/$branch/$filepath#L$lineno"
	# NOTE: default https://
	[[ ! $web_link =~ ^(https?|ftp|file):// ]] && local web_link="https://$web_link"
	echo "$web_link"
}
main "$@"

function is_git_repo_with_message() {
	local message=${1:-"${RED}no git repo here!${DEFAULT}"}
	is_git_repo
	local code=$?
	[[ $code != 0 ]] && echo "$message" >&2
	return $code
}

# github: "git@github.com:user/repo.git"
#         "https://github.com/user/repo.git"
# gerrit: "ssh://user@xxx.co.jp:12345/pj/repo"
# gitlab: "ssh://git@xxx-gitlab.co.jp:12345/user/repo.git"
