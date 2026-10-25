// § xzOvLitKeepsText427
module sub #(parameter P = 1'b0, parameter R = 4'b0, parameter N = 8, parameter logic [3:0] Q = 0, parameter bit [3:0] B = 0, parameter int I = 0, parameter E = 4'd0, parameter X = 2 + 1)(input a, output o);
  assign o = a ^ P[0] ^ R[0] ^ N[0] ^ Q[0] ^ B[0] ^ I[0] ^ E[0] ^ X[0];
endmodule
module top(input a, output [7:0] o);
  sub #(.P('hx)) uP(.a(a), .o(o[0]));
  sub #(.R('hx)) uR(.a(a), .o(o[1]));
  sub #(.N('hx)) uN(.a(a), .o(o[2]));
  sub #(.Q('hx)) uQ(.a(a), .o(o[3]));
  sub #(.B('hx)) uB(.a(a), .o(o[4]));
  sub #(.I('hx)) uI(.a(a), .o(o[5]));
  sub #(.E('hx)) uE(.a(a), .o(o[6]));
  sub #(.X('hx)) uX(.a(a), .o(o[7]));
endmodule
