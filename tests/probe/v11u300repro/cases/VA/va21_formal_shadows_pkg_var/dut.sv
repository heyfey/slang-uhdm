// § retShareActualFoldAbstain300v
package p;
  int x = 6;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
