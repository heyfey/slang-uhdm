// § tdSpecArgTypedefShares470 (the this_t chain through a typedef of a typedef, clones in another package)
package r; class reg_t #(type T = int); T x; endclass endpackage
package a;
  import r::*;
  class C #(int W = 8);
    typedef C #(W) self_t;
    typedef self_t this_t;
    typedef reg_t #(this_t) type_id;
  endclass
endpackage
package t;
  import a::*;
  class K; localparam w = 16; endclass
  typedef C #(K::w) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
