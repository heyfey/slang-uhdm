// § aliasCopyParamUnnamed478 (a package typedef chain used by a class property)
package p;
  class C #(int W = 1, int V = 2);
    typedef C #(W, V) this_t;
    int x;
  endclass
  typedef C #(8, 9) c_t;
  typedef c_t c2_t;
  class D; c2_t h; endclass
endpackage
module top; import p::*; D d; endmodule
