// § retShareActualFoldAbstain300v
package p;
  parameter int t = 2;
  function automatic int f (int a); return a + 1; endfunction
  function automatic int c (int y); begin : b int t; t = y; return f(t); end endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
