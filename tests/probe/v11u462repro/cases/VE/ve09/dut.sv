// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
  typedef e_t ea_t;
endpackage
module m;
  import p::*;
  class C;
    ea_t f;
  endclass
  ea_t v;
endmodule
module n;
  import p::*;
  class K;
    int z;
  endclass
  e_t w;
endmodule
module top;
  m u();
  n x();
endmodule
