// § portExprOperandAtExpr146
module c(.a({b, c}));
  input b;
  input c;
endmodule
module top(input logic x, y);
  c ci(.a({x, y}));
endmodule
