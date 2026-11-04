// § pkgLateTsNetCapture420
package p;
  function automatic void f();
    int b[$];
    foreach (b[i]) b[i] = 0;
  endfunction
endpackage
import p::*;
interface ifc(output reg [7:0] b);
endinterface
module top;
  logic [3:0] b;
  ifc u();
endmodule
