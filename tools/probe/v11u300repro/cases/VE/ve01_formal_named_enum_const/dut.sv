// § retShareActualFoldAbstain300v
package p;
  typedef enum {X0, X1} e_t;
  function int f (int a); return a + 1; endfunction
  function int c (int X0); return f(X0); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
