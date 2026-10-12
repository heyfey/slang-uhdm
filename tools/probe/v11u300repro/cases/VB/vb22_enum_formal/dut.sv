// § pkgRetCallFoldSharesCalleeRet300
package p;
  typedef enum {A, B} e_t; function int f (e_t a); return a + 1; endfunction
  function int c (e_t x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(p::A); endmodule
