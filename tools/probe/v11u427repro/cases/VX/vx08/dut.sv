// § xzOvLitKeepsText427
module sub #(parameter bit [3:0] P = 0) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(8'b1x)) u(o);
endmodule
