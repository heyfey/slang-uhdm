// § undefaultedDefInvalidInst404
module child #(parameter w_p) (input [w_p-1:0] a, output [w_p-1:0] b);
  always @* $display("%b", undeclared_q);
  assign b = a;
endmodule
module child__abstract(); if (0) begin : abstract child not_used(); end endmodule
module top; endmodule
