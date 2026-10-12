// § retShareActualFoldAbstain300v
package p;
  parameter type x = int;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
