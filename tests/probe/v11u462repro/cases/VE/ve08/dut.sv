// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
endpackage
interface zi;
  import p::*;
  e_t w;
endinterface
module m;
  import p::*;
  class C;
    e_t f;
  endclass
  e_t v;
endmodule
module top;
  m u();
  zi i();
endmodule
