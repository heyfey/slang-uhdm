// § tpArrBoundAtLeftOperand196: shift, modulo and a parenthesized quotient on the left
module dut #(parameter int N = 6, parameter type t_t = logic [1:0]) (output t_t o);
  t_t [N>>1:0] a;
  t_t [N%4+1:0] b;
  t_t [(N+1)/2-1:0] c;
  assign o = a[0] ^ b[0] ^ c[0];
endmodule
