// § specValueArgRefObj470
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; localparam d = 32; endclass
endpackage
module top; import p::*; import t::*;
  typedef C #(K::w, K::d) cfg_t;
  cfg_t h;
endmodule
