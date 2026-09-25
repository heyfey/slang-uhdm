// § portExprOperandAtExpr146
module c(.a({b[1:0], e}));
  input [3:0] b;
  input e;
endmodule
module top(input logic [1:0] x, input logic y);
  c ci(.a({x, y}));
endmodule
