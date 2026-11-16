#! /usr/bin/env bash

set -o pipefail # Set the status code take the one that failed not the last one
set -e          # Exit if error happened
set -u          # Exit if use variable that dose not exists

if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

t=3

timeout "${t}m" yes >/dev/null &
timeout "${t}m" sha256sum /dev/zero &

timeout "${t}m" bash -c '
  while true; do
    dd if=/dev/zero of=/tmp/loadtest bs=1M count=500 conv=fdatasync 2>/dev/null
    dd if=/dev/zero of=/tmp/loadtest bs=1M count=200 oflag=append conv=notrunc,fdatasync 2>/dev/null
    rm -f /tmp/loadtest
  done
' &

wait

rm -f /tmp/loadtest
echo "${t}-minute load test finished!"
