// § pkgLateTsNetCapture420
package p;
  function automatic int f();
    int b[4];
    int s = 0;
    foreach (b[i]) s += b[i];
    return s;
  endfunction
endpackage
package q;
  function automatic int g();
    int b[2];
    int s = 0;
    foreach (b[i]) s += b[i];
    return s;
  endfunction
endpackage
module top;
  import q::*;
  logic [7:0] b;
endmodule
