// § genIpsBoundOwner256 (two instances of one module in two scopes, a for-generate operand)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [2:0] t [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign t[i] = c ? a[FW +: PW] : b[WW +: PW];
  end
  assign q = t[0]; assign o = {1'b0, t[1]};
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q, output logic [3:0] o2, output logic [2:0] q2);
  m u (.*);
  for (genvar k = 0; k < 1; k++) begin : gt
    m v (.a(a), .b(b), .c(c), .o(o2), .q(q2));
  end
endmodule
