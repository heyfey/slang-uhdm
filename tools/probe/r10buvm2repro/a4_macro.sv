// r10buvm2 ARM a4 ??? the MACRO-EXPANDED time literal, i.e. the shape SimpleUVM
// and Scoreboard actually write:
//     uvm_root.svh:218   time phase_timeout = `UVM_DEFAULT_TIMEOUT;
// with `define UVM_DEFAULT_TIMEOUT 9200s` in uvm_global_defines.svh.
//
// Golden spans that constant at 218:24-218:29 ??? the MACRO USE's start column
// plus the EXPANDED text's length (5 = strlen "9200s"), not the macro body's
// own location and not the macro use's full width (the use is 20 columns wide).
// The `timescale` here is deliberately NOT 1ps: SS srlgTimeLitVal claims the
// factor table never consults it, and a4 is where that claim is measured.
`timescale 1ns/1ns
`define TMO2 9200s
`define TMO2NS 7ns
`define NUM2 9200

package p4;
  class c4;
    time q01_macro   = `TMO2;      // whole literal from the macro
    time q02_macrons = `TMO2NS;
    time q03_split   = 7ns;      // control: literal written in place
    time q04_direct  = 9200s;      // the un-macroed control, same file
  endclass
endpackage
