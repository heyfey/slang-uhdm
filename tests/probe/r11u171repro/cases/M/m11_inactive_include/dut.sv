// § tsMemberRootFile171
package p;
`ifdef NOPE
`include "other.svh"
`else
`include "defs.svh"
`endif
endpackage
module dut import p::*; (input s_t i, output logic o);
  assign o = i.b;
endmodule
