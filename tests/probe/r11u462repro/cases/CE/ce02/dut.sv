// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
  typedef e_t f_t;
endpackage
module m;
  import p::*;
  class C;
    e_t k;
  endclass
  f_t e;
endmodule
module top;
  m u();
endmodule
