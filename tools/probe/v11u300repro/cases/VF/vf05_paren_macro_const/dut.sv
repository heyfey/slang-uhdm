// § retShareActualFoldAbstain300v
package p;

  function int f (int a); return a + 1; endfunction
  function int c (int x); `define TWO 2
  return (f(`TWO)); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
