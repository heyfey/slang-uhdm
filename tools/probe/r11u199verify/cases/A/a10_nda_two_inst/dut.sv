// § ndaPsBoundOwner192
package p;
  parameter int unsigned W = 3;
endpackage
module sub import p::*; #(parameter int K = 1) (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  wire [31:0] n1 = x[W:0];
  wire [31:0] n2 = x[W+K:K];
  wire [31:0] n3 = x[W:0] & {32{1'b1}};
  logic [31:0] v4 = x[W:0];
  assign y1 = n1;
  assign y2 = n2 | v4;
  assign y3 = n3;
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] z1, output logic [31:0] z2, output logic [31:0] z3);
  sub #(.K(1)) u1 (.x(x), .y1(y1), .y2(y2), .y3(y3));
  sub #(.K(2)) u2 (.x(x), .y1(z1), .y2(z2), .y3(z3));
endmodule
