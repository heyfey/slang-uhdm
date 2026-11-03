// § specValueArgRefObj470 (the typedef inside a class)
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; endclass
  class U;
    typedef C #(K::w, 4) cfg_t;
    cfg_t h;
  endclass
endpackage
module top; import t::*; U u; endmodule
