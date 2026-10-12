// § retShareActualFoldAbstain300v
`define CALLF(v) f(v)
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return `CALLF(2); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
