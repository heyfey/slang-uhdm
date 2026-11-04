// § xzOvLitKeepsText427
module sub #(parameter P = 0) (output [15:0] o);
  wire [15:0] w = P;
  assign o = w;
endmodule
module top(output [15:0] o);
  sub #(.P(8'hx3)) u(o);
endmodule
