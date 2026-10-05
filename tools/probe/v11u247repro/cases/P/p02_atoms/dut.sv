// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void f(byte unsigned a, shortint unsigned b, longint unsigned c);
    pure virtual function void g(integer unsigned d, time unsigned e, int signed h);
  endclass
endpackage
module top;
  import p::*;
  base x;
endmodule
