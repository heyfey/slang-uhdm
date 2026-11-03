// § pkgTdSpecPairsImported470 (a type then a class-scoped value)
package q; parameter int A = 1; parameter int B = 2; endpackage
package p;
  import q::*;
  class C #(type T = int, int D = 8);
    T x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam d = 32; endclass
  typedef C #(byte, K::d) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
