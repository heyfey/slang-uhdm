// § retShareActualFoldAbstain300v
`define XX x
`define ONE 1
package p;
  function int f (int a, int b); return a + b; endfunction
  function int c (int x); return f(.b(`XX), .a(`ONE)); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
