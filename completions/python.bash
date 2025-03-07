#!/bin/bash

# Get user's `site-packages` directory location
user_site_packages_path="$(python -m site --user-site)"
if [ -d "$user_site_packages_path" ]; then
	# Get `_python-argcomplete` file from argcomplete
	python_argcomplete_file="$(find "$user_site_packages_path" -type f -name '_python-argcomplete' | head -n 1)"
	if [ -e "$python_argcomplete_file" ]; then
		python_argcomplete_file="$(realpath "$python_argcomplete_file")"
		source "$python_argcomplete_file"
	fi
fi

unset user_site_packages_path python_argcomplete_file
