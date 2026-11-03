// § specValueArgRefObj470 (a module-local class and typedef)
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
module top;
  import p::*;
  class K; localparam w = 16; endclass
  typedef C #(K::w, 4) cfg_t;
  cfg_t h;
endmodule
