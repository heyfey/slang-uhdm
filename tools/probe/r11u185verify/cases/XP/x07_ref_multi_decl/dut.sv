// § externProtoFormalsFromPrototype175
package p;
  class c;
    int m;
    extern function void f(ref int x, const ref int y, input int a, b = 2);
    extern function new(int s = 1);
  endclass
  function void c::f(ref int x, const ref int y, input int a, b = 2);
    x = y + a + b;
  endfunction
  function c::new(int s = 1);
    m = s;
  endfunction
endpackage
module top;
  import p::*;
  c o; int u, v;
  initial begin o = new(3); o.f(u, v, 1); end
endmodule
