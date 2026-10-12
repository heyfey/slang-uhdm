// § retShareActualFoldAbstain300v
`define KK K
package p;
  parameter int K = 3;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(`KK); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
