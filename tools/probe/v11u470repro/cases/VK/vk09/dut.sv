// § specValueArgRefObj470 (two typedefs over class-scoped names)
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; localparam d = 2; endclass
  typedef C #(K::w, 4) a_t;
  typedef C #(K::d, K::w) b_t;
endpackage
module top; import t::*; a_t h; b_t g; endmodule
