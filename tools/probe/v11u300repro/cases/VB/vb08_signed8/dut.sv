// § pkgRetCallFoldSharesCalleeRet300
package p;
  function logic signed [7:0] f (logic signed [7:0] a); return a + 1; endfunction
  function logic signed [7:0] c (logic signed [7:0] x); return f(x); endfunction
endpackage
module top; logic signed [7:0] r; initial r = p::c(1); endmodule
