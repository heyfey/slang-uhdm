// § tdSpecArgTypedefShares470 (everything at $unit)
class reg_t #(type T = int); T x; endclass
class C #(int W = 8);
  typedef C #(W) this_t;
  typedef reg_t #(this_t) type_id;
endclass
module top; C #(4) h; endmodule
