// § cloneRetNoMintBindsHome232
// virtual and pure prototypes above the caller, extern bodies below, a parameterized class
package p1;
  virtual class b;
    pure virtual function int f(int a);
  endclass
  class c extends b;
    extern virtual function int f(int a);
    function int usef(); return f(3) + this.f(4); endfunction
  endclass
  function int c::f(int a);
    f = a;
    if (a > 2) f = f * 2;
  endfunction
  class d #(int W = 4);
    extern function logic [W-1:0] k();
  endclass
  function logic [W-1:0] d::k();
    k = '1;
    k[0] = 1'b0;
  endfunction
endpackage
package p2;
  import p1::*;
  typedef d#(8) d8;
endpackage
module top(output int o);
  import p2::*;
  import p1::*;
  assign o = 1;
endmodule
