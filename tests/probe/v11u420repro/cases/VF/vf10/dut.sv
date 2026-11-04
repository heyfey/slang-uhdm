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
module child(input logic [2:0] b);
endmodule
module top;
  logic [2:0] w;
  child u(.b(w));
endmodule
