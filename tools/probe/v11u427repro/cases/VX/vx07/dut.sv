// § xzOvLitKeepsText427
module sub #(parameter logic P = 0) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(1'bz)) u(o);
endmodule
