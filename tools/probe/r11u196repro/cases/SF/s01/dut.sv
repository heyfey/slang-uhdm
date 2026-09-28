// § tfFormalTdCloneFile196: package scalar typedefs from one included header, the formals of package functions in another included header (the uvm_bitstream_t shape)
package p;
`include "types.svh"
`include "fns.svh"
endpackage
module top;
  import p::*;
endmodule
