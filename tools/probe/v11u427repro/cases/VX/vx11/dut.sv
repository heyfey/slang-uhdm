// § xzOvLitKeepsText427
module sub #(parameter logic [15:0] P = 0) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(16'h?F)) u(o);
endmodule
