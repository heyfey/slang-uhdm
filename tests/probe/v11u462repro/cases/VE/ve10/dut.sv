// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
endpackage
module zz;
  import p::*;
  class C;
    e_t f;
  endclass
  e_t v;
endmodule
module top;
  import p::*;
  e_t q;
  zz u();
endmodule
