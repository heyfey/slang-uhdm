// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
endpackage
interface ifc; int v; function int g(int z); return p::c(z); endfunction endinterface
module top; ifc i(); int r; assign r = i.g(1); endmodule
