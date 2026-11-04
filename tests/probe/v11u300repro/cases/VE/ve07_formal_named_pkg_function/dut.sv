// § retShareActualFoldAbstain300v
package p;
  function int h (int z); return z; endfunction
  function int f (int a); return a + 1; endfunction
  function int c (int h); return f(h); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
