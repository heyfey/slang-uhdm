#!/bin/bash
# gd.sh <casedir> : golden dump path
h=$(md5sum $1/dut.sv|cut -c1-16); echo /tmp/r11u409_gold/$h/golden.uhdm
