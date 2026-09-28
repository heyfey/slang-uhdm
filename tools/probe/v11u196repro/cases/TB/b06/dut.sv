// § tpArrBoundAtLeftOperand196: a binary right bound, a sum-minus-one, a $bits product and a multi-line left operand
module dut #(parameter int N = 4, parameter type t_t = logic [1:0]) (output t_t o);
  t_t [N-1:N/2] a;
  t_t [N+1-1:0] b;
  t_t [$bits(t_t)*N-1:0] c;
  t_t [N *
       2 - 1:0] d;
  assign o = a[3] ^ b[0] ^ c[0] ^ d[0];
endmodule
