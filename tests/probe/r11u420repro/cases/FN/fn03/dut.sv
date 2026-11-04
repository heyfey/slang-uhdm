// § pkgLateTsNetCapture420
package p;
  function automatic void f();
    int b[$];
    foreach (b[i]) b[i] = 0;
  endfunction
endpackage
interface ifc(output reg [7:0] b);
  import p::*;
endinterface
module top;
  ifc u();
endmodule
