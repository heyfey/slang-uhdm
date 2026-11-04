// § specValueArgRefObj470 (untyped formals, as the sv-tests row writes them)
package p;
  class C #(W = 8, D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; localparam d = 32; endclass
  typedef C #(K::w, K::d) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
