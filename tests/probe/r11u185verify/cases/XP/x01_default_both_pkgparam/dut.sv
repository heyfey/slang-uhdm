// § externProtoFormalsFromPrototype175
package p0;
  localparam int W = 4;
endpackage
package p;
  class c;
    extern function int f(int a,
                          int n = p0::W);
  endclass
  function int c::f(int a, int n = p0::W);
    return a + n;
  endfunction
endpackage
module top;
  import p::*;
  c o; int r;
  initial begin o = new; r = o.f(1); end
endmodule
