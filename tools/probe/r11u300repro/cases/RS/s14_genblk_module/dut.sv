// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top #(parameter N = 2) (output int o [N]);
  for (genvar i = 0; i < N; i++) begin : g
    assign o[i] = p::c(i);
  end
endmodule
