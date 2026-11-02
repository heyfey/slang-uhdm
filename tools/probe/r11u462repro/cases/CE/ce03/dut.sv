// § clsInModEnumLastWriter462
package p;
  class Box #(type T = int);
    T v;
  endclass
  class X; endclass
  typedef Box#(X) bx_t;
  typedef Box#(X) by_t;
endpackage
module m;
  import p::*;
  class C;
    int k;
  endclass
  bx_t b;
endmodule
module top;
  m u();
endmodule
