// § pkgRetCallFoldSharesCalleeRet300
package p;
  typedef logic [3:0] n_t;
  function n_t f (n_t a); return a + 1; endfunction
  function n_t c (n_t x); return f(x); endfunction
endpackage
module top; logic [3:0] r; initial r = p::c(4'h1); endmodule
