// § pkgTdSpecPairsImported470 (one imported parameter, three formals, two written)
package q; parameter int A = 1; endpackage
package p;
  import q::*;
  class C #(type T = int, type U = int, type V = int);
    T x; U y; V z;
  endclass
endpackage
package t;
  import p::*;
  typedef C #(byte, logic) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
