// § retShareActualFoldAbstain300v
package q;
  function int f (int b); return b + 1; endfunction
endpackage
package p;
  parameter int b = 9;
  function int c (int x); return q::f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
