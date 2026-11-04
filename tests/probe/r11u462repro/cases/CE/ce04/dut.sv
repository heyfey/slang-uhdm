// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
endpackage
module m;
  import p::*;
  class C;
    int k;
  endclass
  e_t e;
endmodule
module z;
  import p::*;
  e_t q;
endmodule
module top;
  m u();
  z w();
endmodule
