// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual task runit(integer unsigned k, int signed o, input int unsigned i);
    pure virtual function void f2(int unsigned a, int unsigned b);
    pure virtual function void f3(input int unsigned a, int unsigned b);
  endclass
endpackage
module top;
  import p::*;
  base x;
endmodule
