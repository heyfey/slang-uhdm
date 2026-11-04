// § portExprOperandAtExpr146 § portExprElabDefNets146
module c(.a({b, c}));
  input [1:0] b;
  input [1:0] c;
endmodule
module top(input logic [3:0] x);
  c ci(.a(x));
endmodule
