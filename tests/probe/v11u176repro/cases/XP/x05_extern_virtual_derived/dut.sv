// § externProtoFormalsFromPrototype175
package p;
  class b;
    virtual function int f(int a); return a; endfunction
  endclass
  class d extends b;
    extern virtual function int f(int a);
  endclass
  function int d::f(int a);
    return a + 1;
  endfunction
endpackage
module top;
  import p::*;
  d o; int r;
  initial begin o = new; r = o.f(2); end
endmodule
