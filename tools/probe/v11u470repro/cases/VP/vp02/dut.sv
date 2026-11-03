// § pkgTdSpecPairsImported470 (literal value arguments, the target importing parameters)
package q; parameter int A = 1; parameter int B = 2; endpackage
package p;
  import q::*;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  typedef C #(3, 4) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
