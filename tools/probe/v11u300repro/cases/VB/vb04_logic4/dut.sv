// § pkgRetCallFoldSharesCalleeRet300
package p;
  function logic [3:0] f (logic [3:0] a); return a + 1; endfunction
  function logic [3:0] c (logic [3:0] x); return f(x); endfunction
endpackage
module top; logic [3:0] r; initial r = p::c(1); endmodule
