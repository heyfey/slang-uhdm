// § pkgEnumCastTargetTs411
package p;
  typedef enum { A, B, C } e_t;
  class K;
    parameter e_t P = e_t'(1);
    int v = P;
  endclass
endpackage
module top (output int o);
  p::K k;
  initial begin k = new; o = k.v; end
endmodule
