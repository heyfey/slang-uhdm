// § tdSpecArgTypedefShares470 (two clone packages of one base)
package r; class reg_t #(type T = int); T x; endclass endpackage
package a;
  import r::*;
  class C #(int W = 8);
    typedef C #(W) this_t;
    typedef reg_t #(this_t) type_id;
  endclass
endpackage
package t;
  import a::*;
  class K; localparam w = 16; endclass
  typedef C #(K::w) cfg_t;
endpackage
package u;
  import a::*;
  typedef C #(3) cfg3_t;
endpackage
module top; import t::*; import u::*; cfg_t h; cfg3_t g; endmodule
