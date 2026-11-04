// § tsMemberRootFile171
module dut(input logic [4:0] i, output logic [4:0] o);
  typedef struct packed {
`include "mem.svh"
  } s_t;
  s_t s;
  assign s = i;
  assign o = s;
endmodule
