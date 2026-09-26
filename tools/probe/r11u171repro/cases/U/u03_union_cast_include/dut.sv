// § castUnionCloneFile171
package p;
`include "defs.svh"
endpackage
module dut import p::*; (input logic [7:0] i, output logic [3:0] o);
  u_t d;
  assign d = u_t'(i);
  assign o = d.n[0];
endmodule
