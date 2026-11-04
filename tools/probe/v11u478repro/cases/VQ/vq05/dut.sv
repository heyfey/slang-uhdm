// § aliasCopyParamUnnamed478 (a nested class specialization)
package a;
  class O;
    class A #(int W = 1);
      typedef A #(W) this_t;
    endclass
  endclass
  typedef O::A #(6) A_t;
  class E; A_t h; endclass
endpackage
module top; import a::*; E e; endmodule
