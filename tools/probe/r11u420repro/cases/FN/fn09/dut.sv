// § pkgLateTsNetCapture420
package p;
  class c;
    extern function void f();
  endclass
  function void c::f();
    int b[$];
    foreach (b[i]) b[i] = 0;
  endfunction
endpackage
import p::*;
interface ifc(output reg [7:0] b);
endinterface
module top;
  ifc u();
endmodule
