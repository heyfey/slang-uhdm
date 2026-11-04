// § tfFormalTdCloneFile196: a package typedef declared in a header, the formals of a module function and task in dut.sv through a wildcard import (no call)
package p;
`include "types.svh"
endpackage
module top;
  import p::*;
  function automatic int f(it_t v, input bt_t w);
    return v + w;
  endfunction
  task automatic t(output it_t o, input it_t i [2]);
    o = i[0];
  endtask
endmodule
