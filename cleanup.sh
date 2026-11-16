#! /usr/bin/env bash

set -o pipefail # Set the status code take the one that failed not the last one
set -e          # Exit if error happened
set -u          # Exit if use variable that dose not exists

if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

echo "Are you sure You want to delete NetData?"
read -p "Enter (yes/no):" answer

if [[ "$EUID" -ne 0 ]]; then
    echo "Sudo Privilage is requiered."
    exec sudo "$0" "$@"
fi

if [[ ! ${answer,,} =~ ^y(es)?$ ]]; then
    exit
fi

wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh 1>/dev/null

if [[ $? == 1 ]]; then
    echo "Couldn't reach the website \"https://get.netdata.cloud\"" >&2
    exit 1
fi

echo "netdata-kickstart has been downloaded."

options=("--uninstall" "--non-interactive")

sh /tmp/netdata-kickstart.sh "${options[*]}" 1>/dev/null

if [[ $? == 1 ]]; then
    echo "Something went worng" >&2
    exit 1
fi

rm -rf /tmp/netdata-kickstart.sh

echo

echo "Netdata Has Been Uninstalled."

echo
