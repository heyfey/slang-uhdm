// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
endpackage
interface ifc; import p::*; int v; function int h (int y); return c(y); endfunction endinterface
module top; ifc i(); int r; initial r = i.h(1); endmodule
