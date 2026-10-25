// § xzOvLitKeepsText427
module sub #(parameter int P = 0) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(12'o7x7)) u(o);
endmodule
