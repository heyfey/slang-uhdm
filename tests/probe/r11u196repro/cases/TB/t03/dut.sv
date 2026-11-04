// § tpArrBoundAtLeftOperand196: a parenthesized left operand, a call on the left, a power on the right
module dut #(parameter int N = 3, parameter type t_t = logic [1:0]) (output t_t o);
  t_t [(N)-1:0] a;
  t_t [$clog2(N)+1:0] b;
  t_t [N-2**1:0] d;
  assign o = a[0] ^ b[0] ^ d[0];
endmodule
