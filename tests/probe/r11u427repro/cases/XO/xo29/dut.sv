// § xzOvLitKeepsText427
module sub #(parameter P = 4'b0)(input a, output [3:0] o); assign o = {4{a}} ^ P; endmodule
module top(input a, output [3:0] o, output [3:0] q);
  sub #(.P(4'B10X1)) u1(.a(a), .o(o));
  sub #(.P(4'sbx101)) u2(.a(a), .o(q));
endmodule
