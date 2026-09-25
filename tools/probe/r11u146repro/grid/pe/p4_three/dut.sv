// § portExprOperandAtExpr146
module c(.a({b, e, f}));
  input b, e, f;
endmodule
module top(input logic x, y, z);
  c ci(.a({x, y, z}));
endmodule
