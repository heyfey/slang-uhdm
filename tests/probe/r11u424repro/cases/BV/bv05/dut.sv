// § boundSizedLitKept424
module m #(parameter W = 4) (input logic [W-1:1'b0] a);
  logic [W+1'b1:0] v;
endmodule
module top; logic [3:0] a; m u(a); endmodule
