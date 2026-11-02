// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
endpackage
program pr;
  import p::*;
  class C;
    e_t f;
  endclass
  e_t e;
endprogram
module top;
  pr u();
endmodule
