// § xzOvLitKeepsText427
module sub #(parameter P = 1'b0, parameter R = 4'b0, parameter N = 8, parameter logic [3:0] Q = 0, parameter bit [3:0] B = 0, parameter int I = 0, parameter E = 4'd0, parameter X = 2 + 1)(input a, output o);
  assign o = a ^ P[0] ^ R[0] ^ N[0] ^ Q[0] ^ B[0] ^ I[0] ^ E[0] ^ X[0];
endmodule
module top(input a, output [7:0] o);
  sub #(.P(12'hx0F)) uP(.a(a), .o(o[0]));
  sub #(.R(12'hx0F)) uR(.a(a), .o(o[1]));
  sub #(.N(12'hx0F)) uN(.a(a), .o(o[2]));
  sub #(.Q(12'hx0F)) uQ(.a(a), .o(o[3]));
  sub #(.B(12'hx0F)) uB(.a(a), .o(o[4]));
  sub #(.I(12'hx0F)) uI(.a(a), .o(o[5]));
  sub #(.E(12'hx0F)) uE(.a(a), .o(o[6]));
  sub #(.X(12'hx0F)) uX(.a(a), .o(o[7]));
endmodule
