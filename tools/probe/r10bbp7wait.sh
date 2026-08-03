#!/bin/bash
# r10bbp7wait: block until no verify_golden.py sweep is running (rebuilding
# build/slang-uhdm while a sweep is in flight corrupts the sweep).
until [ "$(pgrep -fc verify_golden.py)" = "0" ]; do sleep 10; done
echo "sweep done"
