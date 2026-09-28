// § tfFormalTdCloneFile196: a package typedef declared in a header, the formals of a module function in dut.sv through a wildcard import
package p;
`include "types.svh"
endpackage
module top(output int o);
  import p::*;
  function automatic int f(it_t v, input bt_t w);
    return v + w;
  endfunction
  assign o = f(4'h1, 1'b1);
endmodule
