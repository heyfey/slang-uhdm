// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
endpackage
module m;
  import p::*;
  class Outer;
    class Inner;
      e_t f;
    endclass
  endclass
  e_t e;
endmodule
module top;
  m u();
endmodule
