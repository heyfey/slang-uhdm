// § pkgTdSpecPairsImported470 (type arguments only, the target importing parameters)
package q; parameter int A = 1; parameter int B = 2; endpackage
package p;
  import q::*;
  class C #(type T = int, type U = int);
    T x; U y;
  endclass
endpackage
package t;
  import p::*;
  typedef C #(byte, shortint) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
