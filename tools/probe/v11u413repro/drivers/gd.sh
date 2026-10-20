#!/bin/bash
h=$(md5sum /tmp/wt_v11u413/tools/probe/v11u413repro/cases/$1/dut.sv | cut -c1-16); sed 's/, id:[0-9]*//' /tmp/v11u413_gold/$h/golden.dump
