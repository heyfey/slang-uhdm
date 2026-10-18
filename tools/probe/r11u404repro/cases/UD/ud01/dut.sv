// § undefaultedDefInvalidInst404
module child #(parameter w_p, parameter int d_p = 2) (input [w_p-1:0] a, output [w_p-1:0] b);
  localparam lp = w_p + 1;
  wire [w_p:0] t;
  assign b = a;
  if (d_p == 0) begin : g
    assign t = 0;
  end
endmodule
module child__abstract(); if (0) begin : abstract child not_used(); end endmodule
module top; endmodule
