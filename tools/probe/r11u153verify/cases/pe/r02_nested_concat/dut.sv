// § portExprOperandAtExpr146 § portExprElabDefNets146
module c(.a({b, {c, d}}));
  input b;
  input c;
  input d;
endmodule
module top(input logic x, y, z);
  c ci(.a({x, y, z}));
endmodule
