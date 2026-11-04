// § tsMemberRootFile171
`include "defs.svh"
module dut(input logic [7:0] i, output logic [7:0] o);
`include "types.svh"
  s_t s;
  assign s = i;
  assign o = s;
endmodule
