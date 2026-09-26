// § tsMemberRootFile171
`include "defs.svh"
module dut (input logic [4:0] i, output logic o);
  `MKS
  s_t v;
  assign v = i;
  assign o = v.b;
endmodule
