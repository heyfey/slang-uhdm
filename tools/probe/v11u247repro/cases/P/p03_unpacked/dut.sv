// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void f(int unsigned a[2], bit [3:0] b[$], int unsigned c = 4);
  endclass
endpackage
module top;
  import p::*;
  base x;
endmodule
