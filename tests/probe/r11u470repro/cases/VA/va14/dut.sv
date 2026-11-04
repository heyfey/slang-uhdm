// § specValueArgRefObj470
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; endclass
  typedef C #(4, K::w) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
