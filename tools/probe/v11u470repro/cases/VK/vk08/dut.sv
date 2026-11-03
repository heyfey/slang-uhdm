// § specValueArgRefObj470 (a type formal before the value formal)
package p;
  class C #(type T = int, int W = 8);
    T x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; endclass
  typedef C #(byte, K::w) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
