#!/bin/bash

# shellcheck disable=SC1090,SC1091

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

\. "$SCRIPT_DIR/utils.sh"

BASH_COMPLETIONS_DIR="$SCRIPT_DIR/completions"

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

# Git-For-Windows completion
if command_exists git; then
	if [ -f /usr/share/git/completion/git-completion.bash ]; then
		source /usr/share/git/completion/git-completion.bash
	elif [ -f /mingw64/share/git/completion/git-completion.bash ]; then
		source /mingw64/share/git/completion/git-completion.bash
	else
		source <(curl -s https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash)
	fi

	# set alias for git
	alias g=git

	# add completion for `git` alias
	if type -t __git_complete &>/dev/null; then
		__git_complete g git
	fi
fi

# source completion files in `BASH_COMPLETIONS_DIR`
for comp_file in "$BASH_COMPLETIONS_DIR"/*.bash; do
	cmd=$(basename "$comp_file")
	if command_exists "${cmd%.*}"; then
		source "$comp_file"
	fi
done
unset BASH_COMPLETIONS_DIR comp_file cmd
unset command_exists
