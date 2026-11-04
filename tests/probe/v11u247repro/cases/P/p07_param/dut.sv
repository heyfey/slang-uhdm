// § pureVirtFormalSignKwTrim247
package p;
  virtual class base #(int W = 4, type T = int);
    pure virtual function void f(int unsigned a, T b, bit [W-1:0] c);
  endclass
  class d extends base #(8, byte);
    virtual function void f(int unsigned a, byte b, bit [7:0] c); endfunction
  endclass
endpackage
module top;
  import p::*;
  d x;
  initial x = new();
endmodule
