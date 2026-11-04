// § tpArrBoundAtLeftOperand196: both bounds folded (N*4-1 : N*2, M*N-1 : M*N-4), an unpacked dimension over the type parameter as a control
module dut #(parameter int unsigned N = 2, parameter int unsigned M = 3,
             parameter type idx_t = logic [3:0]) (output idx_t o1, o2, o3);
  idx_t [N*4-1:N*2] a;
  idx_t [M*N-1:M*N-4] b;
  idx_t u [N*2-1:0];
  assign o1 = a[N*2];
  assign o2 = b[M*N-4];
  assign o3 = u[0];
endmodule
