// § specValueArgRefObj470
package q; parameter int A = 1; parameter int B = 2; endpackage
package p;
  import q::*;
  class C #(int W = 8, int D = 8);
    typedef C #(W, D) this_t;
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; localparam d = 32; endclass
  typedef C #(K::w, K::d) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
