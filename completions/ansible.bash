#!/bin/bash

if type -f register-python-argcomplete >/dev/null; then
	eval "$(register-python-argcomplete ansible)"
	eval "$(register-python-argcomplete ansible-config)"
	eval "$(register-python-argcomplete ansible-console)"
	eval "$(register-python-argcomplete ansible-doc)"
	eval "$(register-python-argcomplete ansible-galaxy)"
	eval "$(register-python-argcomplete ansible-inventory)"
	eval "$(register-python-argcomplete ansible-playbook)"
	eval "$(register-python-argcomplete ansible-pull)"
	eval "$(register-python-argcomplete ansible-vault)"
fi
