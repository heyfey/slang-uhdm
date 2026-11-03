// § specValueArgRefObj470
package r; parameter int X = 16; parameter int Y = 32; endpackage
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  typedef C #(r::X, r::Y) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
