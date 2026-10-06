// § genIpsBoundOwner256 (a for-generate, the select inside a concatenation target)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [7:0] o, output logic [2:0] q);
  logic r [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign {o[i*4+FW +: 2], r[i]} = a[i*3 +: 3];
  end
  assign q = {1'b0, r[0], r[1]};
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [7:0] o, output logic [2:0] q);
  m u (.*);
endmodule
