// § tfFormalTdCloneFile196: output, inout, ref and const ref formals of header-written tasks and functions over a typedef declared in dut.sv's package
package p;
  typedef logic [3:0] nib_t;
`include "tasks.svh"
endpackage
module top;
  import p::*;
  nib_t x, y, z, w;
  initial mv(x, y, z, w);
endmodule
