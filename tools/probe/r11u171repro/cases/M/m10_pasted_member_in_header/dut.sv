// § tsMemberRootFile171
package p;
`include "defs.svh"
endpackage
module dut import p::*; (input s_t i, output logic [1:0] o);
  assign o = i.a_f;
endmodule
