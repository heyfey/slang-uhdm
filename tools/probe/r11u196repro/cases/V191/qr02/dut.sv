// § queueRetTwinDynShape191: a bounded queue typedef of a class type parameter returned by a static method, specialized twice
package p;
  class u #(type T = int);
    typedef T b_t[$:4];
    static function b_t mk(); b_t r; return r; endfunction
  endclass
endpackage
module top;
  p::u #(int) a;
  p::u #(byte) b;
endmodule
