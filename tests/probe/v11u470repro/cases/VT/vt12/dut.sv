// § tdSpecArgTypedefShares470 (the argument typedef names another package's class, clones made in another package)
package r; class reg_t #(type T = int); T x; endclass endpackage
package d; class D; int y; endclass endpackage
package a;
  import r::*;
  import d::*;
  class C #(int W = 8);
    typedef D this_t;
    typedef reg_t #(this_t) type_id;
  endclass
endpackage
package t;
  import a::*;
  class K; localparam w = 16; endclass
  typedef C #(K::w) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
