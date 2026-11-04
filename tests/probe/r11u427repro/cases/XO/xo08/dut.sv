// § xzOvLitKeepsText427
module sub #(parameter P = 1'b0, parameter R = 4'b0, parameter N = 8, parameter logic [3:0] Q = 0, parameter bit [3:0] B = 0, parameter int I = 0, parameter E = 4'd0, parameter X = 2 + 1)(input a, output o);
  assign o = a ^ P[0] ^ R[0] ^ N[0] ^ Q[0] ^ B[0] ^ I[0] ^ E[0] ^ X[0];
endmodule
module top(input a, output [7:0] o);
  sub #(.P(4'bZ)) uP(.a(a), .o(o[0]));
  sub #(.R(4'bZ)) uR(.a(a), .o(o[1]));
  sub #(.N(4'bZ)) uN(.a(a), .o(o[2]));
  sub #(.Q(4'bZ)) uQ(.a(a), .o(o[3]));
  sub #(.B(4'bZ)) uB(.a(a), .o(o[4]));
  sub #(.I(4'bZ)) uI(.a(a), .o(o[5]));
  sub #(.E(4'bZ)) uE(.a(a), .o(o[6]));
  sub #(.X(4'bZ)) uX(.a(a), .o(o[7]));
endmodule
