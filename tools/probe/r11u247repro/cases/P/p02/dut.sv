// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void seta(int signed a, byte unsigned b, shortint c, longint signed d);
    pure virtual task runit(input integer unsigned k, output int signed o);
  endclass
endpackage
module top;
  import p::*;
  base x;
endmodule
