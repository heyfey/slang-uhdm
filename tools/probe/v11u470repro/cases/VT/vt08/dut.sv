// § tdSpecArgTypedefShares470 (the specialization a class property of another class)
package r; class reg_t #(type T = int); T x; endclass endpackage
package a;
  import r::*;
  class C #(int W = 8);
    typedef C #(W) this_t;
    typedef reg_t #(this_t) type_id;
  endclass
  class U; C #(3) h; endclass
endpackage
module top; import a::*; U u; endmodule
