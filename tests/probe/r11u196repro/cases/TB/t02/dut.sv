// § tpArrBoundAtLeftOperand196: left-deep sums, a product on the left, a leaf on the left (control)
module dut #(parameter int N = 3, parameter int M = 2, parameter type t_t = logic [1:0]) (output t_t o);
  t_t [N+M-1:0] a;
  t_t [N*2-1:0] b;
  t_t [N-1:0] c;
  t_t [3:M-1] d;
  assign o = a[0] ^ b[0] ^ c[0] ^ d[3];
endmodule
