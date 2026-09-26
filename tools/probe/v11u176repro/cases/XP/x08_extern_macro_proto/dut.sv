// § externProtoFormalsFromPrototype175
`define PROTO(n) extern function int n(int a, int b);
package p;
  class k;
    `PROTO(f)
  endclass
  function int k::f(int a, int b);
    return a - b;
  endfunction
endpackage
module top;
  import p::*;
  k o; int r;
  initial begin o = new; r = o.f(5, 2); end
endmodule
