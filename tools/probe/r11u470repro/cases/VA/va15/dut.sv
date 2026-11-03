// § specValueArgRefObj470
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package r;
  class K; localparam w = 16; localparam d = 32; endclass
endpackage
package t;
  import p::*;
  typedef C #(r::K::w, r::K::d) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
