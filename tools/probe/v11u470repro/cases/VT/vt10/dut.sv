// § tdSpecArgTypedefShares470 (base used plain and specialized)
package r; class reg_t #(type T = int); T x; endclass endpackage
package a;
  import r::*;
  class C #(int W = 8);
    typedef C #(W) this_t;
    typedef reg_t #(this_t) type_id;
  endclass
endpackage
module top; import a::*; C h; C #(6) g; endmodule
