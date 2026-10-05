// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void f(const ref int unsigned a, var int unsigned b, ref int unsigned c);
    pure virtual function void g(output int unsigned d, inout bit [3:0] e);
  endclass
endpackage
module top;
  import p::*;
  base x;
endmodule
