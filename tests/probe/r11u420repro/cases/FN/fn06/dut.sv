// § pkgLateTsLoopVarCapture420
package p;
  function automatic void f();
    int arr[$];
    foreach (arr[b]) arr[b] = 0;
  endfunction
endpackage
import p::*;
interface ifc(output reg [7:0] b);
endinterface
module top;
  ifc u();
endmodule
