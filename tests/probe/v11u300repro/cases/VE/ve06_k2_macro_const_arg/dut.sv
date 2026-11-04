// § retShareActualFoldAbstain300v
`define ONE 1
package p;
  function int g (int a); return $urandom(); endfunction
  function int c (int x); return g(`ONE) == 0; endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
