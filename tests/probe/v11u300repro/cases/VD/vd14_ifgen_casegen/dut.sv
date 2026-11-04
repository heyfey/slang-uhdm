// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top #(parameter int M = 1) (input int i, output int o, output int o2);
  if (M == 1) begin : a assign o = p::c(i); end else begin : b assign o = 0; end
  case (M) 1: begin : cc assign o2 = p::f(i) + p::c(i); end default: begin : dd assign o2 = 0; end endcase
endmodule
