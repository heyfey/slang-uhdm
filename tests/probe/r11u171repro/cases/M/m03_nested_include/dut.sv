// § tsMemberRootFile171
package p;
`include "outer.svh"
endpackage
module dut import p::*; (input u_t i, output logic o);
  assign o = i.s.g;
endmodule
