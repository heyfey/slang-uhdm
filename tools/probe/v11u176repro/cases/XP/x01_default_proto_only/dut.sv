// § externProtoFormalsFromPrototype175
package p;
  class k;
    extern function int f(int a, int b = 5);
  endclass
  function int k::f(int a, int b);
    return a + b;
  endfunction
endpackage
module top;
  import p::*;
  k o; int r;
  initial begin o = new; r = o.f(1); end
endmodule
