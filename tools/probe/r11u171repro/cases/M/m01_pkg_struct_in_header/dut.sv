// § tsMemberRootFile171
package p;
`include "defs.svh"
endpackage
module dut import p::*; (input s_t i, output logic [3:0] o);
  assign o = i.a ^ i.b;
endmodule
