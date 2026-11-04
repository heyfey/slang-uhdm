// § pkgRetCallFoldSharesCalleeRet300
package p;
  function logic [7:0] f (logic [7:0] a); return a + 1; endfunction
  function logic [7:0] c (logic [7:0] x); return f(x); endfunction
endpackage
module top; logic [7:0] r; initial r = p::c(8'h1); endmodule
