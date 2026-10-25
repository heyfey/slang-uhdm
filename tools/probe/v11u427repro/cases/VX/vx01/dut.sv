// § xzOvLitKeepsText427
module sub #(parameter P = 4'b0) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(4'b1x0x)) u(o);
endmodule
