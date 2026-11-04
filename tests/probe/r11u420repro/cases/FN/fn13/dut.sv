// § pkgLateTsLoopVarCapture420
package p;
  function automatic void f();
    int arr[4];
    foreach (arr[c]) arr[c] = 0;
  endfunction
endpackage
import p::*;
module adder(input [8:0] c);
endmodule
interface ifc(input [8:0] c);
endinterface
module top;
  logic [8:0] w;
  ifc u(.c(w));
  adder d(.c(w));
endmodule
