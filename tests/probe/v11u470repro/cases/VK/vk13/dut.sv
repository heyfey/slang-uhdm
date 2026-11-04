// § specValueArgRefObj470 (the target class itself imports a package with parameters)
package q; parameter int A = 1; endpackage
package p;
  import q::*;
  class C #(W = 8, D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; localparam w = 16; endclass
  typedef C #(K::w, 3) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
