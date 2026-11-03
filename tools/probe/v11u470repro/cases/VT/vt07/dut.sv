// § tdSpecArgTypedefShares470 (a package typedef as the argument)
package r; class reg_t #(type T = int); T x; endclass endpackage
package a;
  import r::*;
  typedef logic [3:0] nib_t;
  class C #(int W = 8);
    typedef reg_t #(nib_t) type_id;
  endclass
endpackage
module top; import a::*; C #(4) h; endmodule
