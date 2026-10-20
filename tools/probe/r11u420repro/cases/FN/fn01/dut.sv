// § pkgLateTsNetCapture420
package p;
  class c;
    function void f();
      int b[$];
      foreach (b[i]) b[i] = 0;
    endfunction
  endclass
endpackage
import p::*;
interface ifc(output reg [7:0] b);
endinterface
module top;
  ifc u();
endmodule
