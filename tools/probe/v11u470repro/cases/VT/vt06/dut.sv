// § tdSpecArgTypedefShares470 (two typedef arguments)
package r; class reg2_t #(type T = int, type U = int); T x; U y; endclass endpackage
package a;
  import r::*;
  class C #(int W = 8);
    typedef C #(W) this_t;
    typedef reg2_t #(this_t, this_t) type_id;
  endclass
endpackage
module top; import a::*; C #(4) h; endmodule
