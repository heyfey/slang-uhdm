// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void f(int
       unsigned a, bit
       [3:0] b);
  endclass
endpackage
module top;
  import p::*;
  base x;
endmodule
