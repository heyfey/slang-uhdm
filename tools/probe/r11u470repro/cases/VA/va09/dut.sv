// § specValueArgRefObj470
package p;
  class E #(int W = 8, type T = int);
    T x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; endclass
  typedef E #(K::w, byte) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
