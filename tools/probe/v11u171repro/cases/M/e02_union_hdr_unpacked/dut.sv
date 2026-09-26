// § tsMemberRootFile171
`include "h.svh"
module dut(input logic [7:0] i, output logic [7:0] o);
  p::s_t s;
  assign s.u = i;
  assign o = s.u.w;
endmodule
