// § castUnionCloneFile171
`include "h.svh"
module dut(input logic [7:0] i, output logic [3:0] o, output logic [1:0] r);
  q::u_t a;
  q::v_t b;
  assign a = q::u_t'(i);
  assign b = q::v_t'(i[3:0]);
  assign o = a.n[1];
  assign r = b.n[0];
endmodule
