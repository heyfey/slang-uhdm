// § xzOvLitKeepsText427
module sub #(parameter P = 4'b0, parameter H = 8'h0)(input a, output o); assign o = a ^ P[0] ^ H[0]; endmodule
module top(input a, output [1:0] o);
  sub #(.P(4'b1_0_x_1), .H(8'h?F)) u1(.a(a), .o(o[0]));
  sub #(.P(4'd?), .H(8'o7z)) u2(.a(a), .o(o[1]));
endmodule
