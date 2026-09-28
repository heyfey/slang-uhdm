// § ndaPsBoundOwner192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module sub import p::*; (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4, output logic [31:0] y5);
  wire [31:0] w1 = x[S:0];
  wire [31:0] w2 = {1'b0, x[S:0]};
  wire [31:0] w3 = x[S-1:0];
  wire [31:0] w4 = x[p::S:0];
  wire [31:0] w5 = {x[31:S], 1'b0};
  assign y5 = w5;
  assign y1 = w1;
  assign y2 = w2;
  assign y3 = w3;
  assign y4 = w4;
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4, output logic [31:0] y5);
  sub u (.*);
endmodule
