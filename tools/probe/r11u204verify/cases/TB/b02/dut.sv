// § tpArrBoundAtLeftOperand196: calls and casts as left operands: a constant user function, int'(N), unsigned'(N), $clog2(N*4), $bits of the type parameter
module dut #(parameter int unsigned N = 4, parameter type idx_t = logic [2:0]) (output idx_t o1, o2, o3, o4, o5);
  function automatic int unsigned f(int unsigned x); return x + 1; endfunction
  idx_t [f(N)-1:0] a;
  idx_t [int'(N)-1:0] b;
  idx_t [unsigned'(N)+1:0] c;
  idx_t [$clog2(N*4)-1:0] d;
  idx_t [$bits(idx_t)*2-1:0] e;
  assign o1 = a[0];
  assign o2 = b[0];
  assign o3 = c[0];
  assign o4 = d[0];
  assign o5 = e[0];
endmodule
