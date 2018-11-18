#!/bin/bash
set -ex

#=======================================
# Functions
#=======================================

RESTORE='\033[0m'
RED='\033[00;31m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
GREEN='\033[00;32m'

function color_echo {
	color=$1
	msg=$2
	echo -e "${color}${msg}${RESTORE}"
}

function echo_fail {
	msg=$1
	echo
	color_echo "${RED}" "${msg}"
	exit 1
}

function echo_warn {
	msg=$1
	color_echo "${YELLOW}" "${msg}"
}

function echo_info {
	msg=$1
	echo
	color_echo "${BLUE}" "${msg}"
}

function echo_details {
	msg=$1
	echo "  ${msg}"
}

function echo_done {
	msg=$1
	color_echo "${GREEN}" "  ${msg}"
}

function validate_required_input {
	key=$1
	value=$2
	if [ -z "${value}" ] ; then
		echo_fail "Missing required input: ${key}"
	fi
}

#=======================================
# Main
#=======================================

#
# Validate parameters
echo_info "Configs:"
echo_info "* geckoboard_api_key: **"
echo_info "* widget_key: ${widget_key}"
echo_info "* build_number: ${build_number}"
echo_info "* build_status: ${build_status}"

echo

validate_required_input "geckoboard_api_key" ${geckoboard_api_key}
validate_required_input "widget_key" ${widget_key}

# - Send request
if [ "$build_status" = "0" ] ; then
    message="Build succeeded! (#$build_number)"
else 
    message="Build failed! (#$build_number)"
fi

response=$(curl http://push.geckoboard.com/v1/send/$widget_key -d "{\"api_key\":\"$geckoboard_api_key\", \"data\":{\"item\":[{\"text\":\"$message\",\"type\":0}]}}")

# - Exit
if [ "${response}" != '{"success":true}' ] ; then
    echo_fail "Failed dashboarding update: ${response}"
    exit 1 #failure
else
    echo_info "Dashboard is updated successfully"
    exit 0 #success
fi
