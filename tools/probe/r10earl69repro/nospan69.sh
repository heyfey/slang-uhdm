#!/usr/bin/env bash
# r10earl69 — strip the JUDGE-INVISIBLE fields (span, tsspan, afn) from a
# cen67 census so score69.py never scores a span (earl60's attrv60.py lesson:
# a span-carrying payload HID an Instance flip inside STILL-WRONG).
# MEASUREMENT ONLY.  usage: nospan67.sh < cells > cells.nospan
sed 's/ span=[^ ]*//g; s/ tsspan=[^ ]*//g; s/ afn=[^ ]*//g'
