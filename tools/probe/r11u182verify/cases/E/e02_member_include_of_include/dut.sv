// § tsMemberRootFile171
module dut (input logic [7:0] i, output logic [3:0] o);
  typedef struct packed {
`include "h1.svh"
    logic v;
  } s_t;
  s_t x;
  assign x = {i, 1'b0};
  assign o = x.lo;
endmodule
