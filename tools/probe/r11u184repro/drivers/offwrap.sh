#!/bin/bash
# the law binary with every r11u184 law switched off (SLANG_UHDM for verify_golden.py; LAWBIN names the frozen binary)
R11U184_OFF=1 exec ${LAWBIN:?LAWBIN unset} "$@"
