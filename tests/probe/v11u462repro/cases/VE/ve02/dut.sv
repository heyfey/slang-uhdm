// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
endpackage
module a_m;
  import p::*;
  class K;
    e_t f;
  endclass
  e_t e;
endmodule
module b_m;
  import p::*;
  e_t e;
endmodule
module top;
  a_m x();
  b_m y();
endmodule
