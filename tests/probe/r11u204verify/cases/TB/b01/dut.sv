// § tpArrBoundAtLeftOperand196: products and nested sums as left operands: N*M+2, N*(M+1)-1, N+M*2-1, N-M+3
module dut #(parameter int unsigned N = 3, parameter int unsigned M = 2,
             parameter type idx_t = logic [1:0]) (output idx_t o1, o2, o3, o4);
  idx_t [N*M+2:0] a;
  idx_t [N*(M+1)-1:0] b;
  idx_t [N+M*2-1:0] c;
  idx_t [N-M+3:0] d;
  assign o1 = a[0];
  assign o2 = b[0];
  assign o3 = c[0];
  assign o4 = d[0];
endmodule
