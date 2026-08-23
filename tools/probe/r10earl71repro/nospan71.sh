#!/usr/bin/env bash
# r10earl71 — strip the JUDGE-INVISIBLE fields (span, tsspan, afn) from a
# cen70 census so score70.py never scores a span (earl60's attrv60.py lesson:
# a span-carrying payload HID an Instance flip inside STILL-WRONG).
# MEASUREMENT ONLY.  usage: nospan70.sh < cells > cells.nospan
sed 's/ span=[^ ]*//g; s/ tsspan=[^ ]*//g; s/ afn=[^ ]*//g'
