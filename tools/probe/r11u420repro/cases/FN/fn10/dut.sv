// § pkgLateTsNetCapture420
package p;
  task automatic t(ref int b[4]);
    foreach (b[i]) b[i] = 0;
  endtask
endpackage
import p::*;
module m(input [3:0] b);
endmodule
module top;
  logic [3:0] w;
  m u(.b(w));
endmodule
