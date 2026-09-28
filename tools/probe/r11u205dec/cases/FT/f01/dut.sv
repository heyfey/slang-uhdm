// r11u205 FT f01: a package function formal typed by a package `typedef int` (BuildUVMPkg #3245's uvm_action)
package p;
  typedef int act_t;
  function automatic bit f(string s, output act_t a);
    a = 1;
    return 1'b1;
  endfunction
endpackage
module dut(output logic o);
  import p::*;
  act_t x;
  assign o = 1'b0;
endmodule
