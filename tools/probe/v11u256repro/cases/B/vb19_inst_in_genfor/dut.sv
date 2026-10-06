// § elabBodyIpsBoundSelName256 (the module instantiated inside a for-generate and an if-generate of its parent, a ternary branch)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [2:0] q);
  assign q = c ? a[FW +: PW] : b[WW +: PW];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [2:0] q [2], output logic [2:0] r);
  for (genvar k = 0; k < 2; k++) begin : gt
    m u (.a(a), .b(b), .c(c), .q(q[k]));
  end
  if (1) begin : gi
    m v (.a(a), .b(b), .c(c), .q(r));
  end
endmodule
