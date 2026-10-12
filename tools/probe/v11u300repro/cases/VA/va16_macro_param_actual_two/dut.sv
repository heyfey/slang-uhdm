// § retShareActualFoldAbstain300v
`define PK p::K
package p;
  parameter int K = 3;
  function int f (int a, int b); return a + b; endfunction
  function int c (int x); return f(x, `PK); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
