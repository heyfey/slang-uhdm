// § pkgLateTsNetCapture420
package p;
  function automatic int f(int b[]);
    int s = 0;
    foreach (b[i]) s += b[i];
    return s;
  endfunction
endpackage
import p::*;
interface ifc(input logic [1:0] b);
endinterface
module top;
  logic [1:0] w;
  ifc u(w);
  logic b;
endmodule
