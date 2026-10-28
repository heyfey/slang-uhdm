#!/bin/bash
c=$(cd $1 && pwd); h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12); echo /tmp/r11u455_scr/gold/$h/slpp_all/surelog.uhdm
