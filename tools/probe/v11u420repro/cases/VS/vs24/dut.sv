// § seqAndOrLogOp420
module top(input logic clk, clk2, rst, a, b, c, d, input logic [3:0] v);
  property p; @(posedge clk) a |-> (b or c) and d; endproperty
  assume property (p);
endmodule
