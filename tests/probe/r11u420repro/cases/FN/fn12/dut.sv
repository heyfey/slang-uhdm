// § pkgLateTsNetCapture420
package p;
  function automatic void f();
    int b[$];
    foreach (b[i]) b[i] = 0;
  endfunction
endpackage
module m(input [3:0] b);
  import p::f;
endmodule
module top;
  logic [3:0] w;
  m u(.b(w));
endmodule
