// § tsMemberRootFile171
package p;
`include "defs.svh"
endpackage
module dut import p::*; (input s_t i, output logic o);
  assign o = i.b;
endmodule
