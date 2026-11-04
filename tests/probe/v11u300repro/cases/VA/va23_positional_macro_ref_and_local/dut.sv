// § retShareActualFoldAbstain300v
`define XX x
package p;
  function int f (int a, int b); return a + b; endfunction
  function int c (int x, int y); return f(`XX, y); endfunction
endpackage
module top; int r; initial r = p::c(1, 2); endmodule
