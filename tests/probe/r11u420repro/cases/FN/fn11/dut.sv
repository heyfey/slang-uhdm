// § pkgLateTsNetCapture420
package p;
  function automatic void f();
    int b[$];
    foreach (b[i]) b[i] = 0;
  endfunction
endpackage
import p::*;
module top;
  bit [6:0] b;
endmodule
