// § portExprOperandAtExpr146
module c(.a({b, cc}), .d(e));
  input b, cc; input e;
endmodule
module top(input x, input y, input z);
  c u(.a({x, y}), .d(z));
endmodule
