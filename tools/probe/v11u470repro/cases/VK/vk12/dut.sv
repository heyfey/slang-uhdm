// § specValueArgRefObj470 (the typedef also used as another class's property)
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; endclass
  typedef C #(K::w, 4) cfg_t;
  class U; cfg_t h; endclass
endpackage
module top; import t::*; U u; cfg_t g; endmodule
