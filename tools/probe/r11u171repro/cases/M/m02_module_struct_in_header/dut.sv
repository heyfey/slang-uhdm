// § tsMemberRootFile171
module dut (input logic [2:0] i, output logic o);
`include "defs.svh"
  m_t v;
  assign v = i;
  assign o = v.y;
endmodule
