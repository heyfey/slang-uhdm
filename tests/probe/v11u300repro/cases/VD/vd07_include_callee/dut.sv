// § pkgRetCallFoldSharesCalleeRet300
`include "inc.svh"
package p;
  function int c (int x); return q::f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
