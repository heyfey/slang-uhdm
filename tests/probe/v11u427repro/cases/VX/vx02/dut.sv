// § xzOvLitKeepsText427
module sub #(parameter logic [7:0] P = 0) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(4'bz1)) u(o);
endmodule
