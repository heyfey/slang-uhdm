// § tdSpecArgTypedefShares470 (the argument typedef names another package's class)
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
module top; import a::*; C #(4) h; endmodule
