// § pkgLateTsNetCapture420
package p;
  function automatic void f();
    int b[$];
    foreach (b[i]) b[i] = 0;
  endfunction
endpackage
module m(input [2:0] b);
endmodule
module top;
  import p::*;
  logic [2:0] w;
  m d(.b(w));
endmodule
