// § xzOvLitKeepsText427
module sub #(parameter logic [3:0] P = 0) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(8'b10x1_0011)) u(o);
endmodule
