// § pkgRetCallFoldSharesCalleeRet300
package p;
  typedef struct packed { logic [3:0] a; } s_t; function s_t f (s_t a); return a + 1; endfunction
  function s_t c (s_t x); return f(x); endfunction
endpackage
module top; p::s_t r; initial r = p::c(1); endmodule
