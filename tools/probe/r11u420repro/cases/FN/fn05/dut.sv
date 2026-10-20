// § pkgLateTsNetCapture420
package p;
  function automatic void f();
    int b[4];
    foreach (b[i]) b[i] = 0;
  endfunction
endpackage
import p::*;
module m(input [5:0] b);
endmodule
module top;
  logic [5:0] w;
  m u(.b(w));
endmodule
