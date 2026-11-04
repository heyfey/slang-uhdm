// § pureVirtFormalSignKwTrim247
`define T(x) x
`define U int unsigned
package p;
  virtual class base;
    pure virtual function void f(`T(int unsigned) a, `U b, `T(bit) [3:0] c);
  endclass
endpackage
module top;
  import p::*;
  base x;
endmodule
