// § specValueArgRefObj470
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; endclass
  typedef C #(K::w, 4) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
