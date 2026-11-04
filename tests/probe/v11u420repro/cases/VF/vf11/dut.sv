// § pkgLateTsNetCapture420
package p;
  function automatic int f();
    int b[4];
    int s = 0;
    foreach (b[i]) s += b[i];
    return s;
  endfunction
endpackage
import p::*;
module top;
  assign b = 1'b1;
endmodule
