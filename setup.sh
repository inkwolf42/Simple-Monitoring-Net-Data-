#! /usr/bin/env bash

set -o pipefail # Set the status code take the one that failed not the last one
set -e          # Exit if error happened
set -u          # Exit if use variable that dose not exists

if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

if [[ "$EUID" -ne 0 ]]; then
    echo "Sudo Privilage is requiered."
    exec sudo "$0" "$@"
fi

stable=1
auto_update=0
disable=0
re_install=0

while [[ $# != 0 && $1 =~ -.* ]]; do
    case "$1" in
    -n | --nightly)
        stable=0
        ;;
    -a | --auto-update)
        auto_update=1
        ;;
    -d | --disable)
        disable=1
        ;;
    -r | --re-install)
        re_install=1
        ;;
    *)
        echo "Invalid Option $1 " >&2
        exit 1
        ;;
    esac
    shift
done

wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh 1>/dev/null

if [[ $? == 1 ]]; then
    echo "Couldn't reach the website \"https://get.netdata.cloud\"" >&2
    exit 1
fi

echo "netdata-kickstart has been downloaded."

options=("--non-interactive")

if [[ $stable == 1 ]]; then
    options+=("--stable-channel")
fi

if [[ $re_install == 1 ]]; then
    options+=("--reinstall")
fi

if [[ $auto_update == 0 ]]; then
    options+=("--no-updates")
fi

sh /tmp/netdata-kickstart.sh "${options[*]}" 1>/dev/null

if [[ $? == 1 ]]; then
    echo "Something went worng" >&2
    exit 1
fi

rm -rf /tmp/netdata-kickstart.sh

echo "Netdata Has Been Installed."

if [[ $disable == 1 ]]; then
    echo "Netdata Has Not Been Enabled."
else
    echo "Enabling Netdata."
    sudo systemctl enable --now netdata
    echo "Netdata Has Started."
    local_ip=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
    echo "You can visit \"http://localhost:19999\" to verify. (OR http:${local_ip}:19999)"
fi

echo
