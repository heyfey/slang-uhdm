// § pkgLateTsNetCapture420
package p;
  function automatic void f();
    int b[$];
    foreach (b[i]) b[i] = 0;
  endfunction
endpackage
import p::*;
module m(input [2:0] b);
endmodule
interface ifc(output reg [7:0] b);
endinterface
module top;
  logic [2:0] w;
  m d(.b(w));
  ifc u();
endmodule
