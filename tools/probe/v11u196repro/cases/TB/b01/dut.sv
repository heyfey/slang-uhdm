// § tpArrBoundAtLeftOperand196: a sized literal left operand (IntegerVector, not a LiteralExpression) and an unbased-unsized one
module dut #(parameter int N = 3, parameter type t_t = logic [1:0]) (output t_t o);
  t_t [4'd3+N:0] a;
  t_t [8'h2*N-1:0] b;
  assign o = a[0] ^ b[0];
endmodule
