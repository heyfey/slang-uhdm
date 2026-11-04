// § pureVirtFormalSignKwTrim247
package p;
  import "DPI-C" function void cf(int unsigned a, bit [3:0] b);
  virtual class base;
    pure virtual function void f(int unsigned a);
    extern virtual function void g(int unsigned a);
  endclass
  function void base::g(int unsigned a); endfunction
endpackage
module top;
  import p::*;
  base x;
  initial cf(1, 2);
endmodule
