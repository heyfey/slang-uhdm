// § tdSpecArgTypedefShares470 (the argument typedef names a struct)
package r; class reg_t #(type T = int); T x; endclass endpackage
package a;
  import r::*;
  class C #(int W = 8);
    typedef struct packed { logic [W-1:0] f; } this_t;
    typedef reg_t #(this_t) type_id;
  endclass
endpackage
module top; import a::*; C #(4) h; endmodule
