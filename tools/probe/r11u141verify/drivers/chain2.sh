#!/bin/bash
while kill -0 2326073 2>/dev/null; do sleep 20; done
/tmp/r11u141_drv/sweepchain.sh "30:R11U130_OFF:probe surelog uhdm2rtlil" "31:R11U131_OFF:probe surelog uhdm2rtlil" "34:R11U134_OFF:probe surelog uhdm2rtlil" "Xa:R11U130_OFF,R11U131_OFF:probe surelog uhdm2rtlil" "Xb:R11U130_OFF,R11U134_OFF:probe surelog uhdm2rtlil" "Xc:R11U131_OFF,R11U134_OFF:probe surelog uhdm2rtlil"
