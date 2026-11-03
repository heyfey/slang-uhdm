// § specValueArgRefObj470 (a class property, not a typedef)
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; localparam d = 32; endclass
  class U;
    C #(K::w, K::d) h;
  endclass
endpackage
module top; import t::*; U u; endmodule
