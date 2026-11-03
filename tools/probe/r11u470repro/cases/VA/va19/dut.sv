// § specValueArgRefObj470
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; localparam d = 32; endclass
  typedef C #(K::w, K::d) cfg_t;
  typedef cfg_t cfg2_t;
endpackage
module top; import t::*; cfg2_t h; endmodule
