// § specValueArgRefObj470
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; static const int w = 16; static const int d = 32; endclass
  typedef C #(K::w, K::d) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
