// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top; import p::*; int r; wire [7:0] w; assign w = c(3); initial r = c(1); endmodule
