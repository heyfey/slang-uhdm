// § portExprOperandAtExpr146 § portExprElabDefNets146
module c(.q({b, c}), .i(i));
  input i;
  output b;
  output c;
  assign b = i;
  assign c = ~i;
endmodule
module top(input logic x, output logic [1:0] y);
  c ci(.q(y), .i(x));
endmodule
