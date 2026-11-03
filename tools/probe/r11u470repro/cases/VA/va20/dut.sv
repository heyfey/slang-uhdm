// § specValueArgRefObj470
package p;
  class C #(int W = 8, type T = int, int D = 8);
    T x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; localparam d = 32; endclass
  typedef C #(K::w, byte, K::d) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
