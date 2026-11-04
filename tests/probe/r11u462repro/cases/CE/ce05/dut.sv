// § clsInModEnumLastWriter462
package p;
  typedef enum logic [2:0] { A, B } e_t;
endpackage
module m;
  import p::*;
  class C;
    class D;
      int j;
    endclass
    int k;
  endclass
  e_t e;
endmodule
module top;
  m u();
endmodule
