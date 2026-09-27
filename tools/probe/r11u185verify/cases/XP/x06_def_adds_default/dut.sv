// § externProtoFormalsFromPrototype175
package p;
  class c;
    extern function int f(int a, int b);
    extern function int g(int a, int b = 7);
  endclass
  function int c::f(int a, int b);
    int t;
    t = a * b;
    return t;
  endfunction
  function int c::g(int a, int b);
    return a - b;
  endfunction
endpackage
module top;
  import p::*;
  c o; int r;
  initial begin o = new; r = o.f(1, 2) + o.g(3); end
endmodule
