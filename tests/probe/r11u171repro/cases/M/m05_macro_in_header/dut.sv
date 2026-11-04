// § tsMemberRootFile171
`include "mac.svh"
package p;
  `MK_T(t_t)
endpackage
module dut import p::*; (input t_t i, output logic o);
  assign o = i.hi;
endmodule
