// § xzOvLitKeepsText427
module sub #(parameter P = 0) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(8'dx)) u(o);
endmodule
