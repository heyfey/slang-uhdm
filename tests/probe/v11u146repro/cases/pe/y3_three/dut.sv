// § portExprOperandAtExpr146
module c(.a({b, cc, dd}));
  input b, cc, dd;
endmodule
module top(input x, input y, input w);
  c u(.a({x, y, w}));
endmodule
