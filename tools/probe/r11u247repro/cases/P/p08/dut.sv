// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void f(int unsigned a = 3, int signed b = -1);
    pure virtual function void g(bit signed [3:0] a, logic unsigned b, int unsigned c[2]);
    pure virtual function void h(ref int unsigned r, output byte signed o, int unsigned after);
  endclass
endpackage
module top;
  import p::*;
  base x;
endmodule
