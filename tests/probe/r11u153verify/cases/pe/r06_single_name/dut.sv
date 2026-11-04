// § portExprOperandAtExpr146 § portExprElabDefNets146
module c(.a(b));
  input b;
endmodule
module top(input logic x);
  c ci(.a(x));
endmodule
