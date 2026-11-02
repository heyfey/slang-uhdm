// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
  class G #(type T = int);
    T x;
  endclass
  typedef G #(e_t) ge_t;
endpackage
module m;
  import p::*;
  class C;
    ge_t h;
  endclass
  e_t e;
endmodule
module top;
  m u();
endmodule
