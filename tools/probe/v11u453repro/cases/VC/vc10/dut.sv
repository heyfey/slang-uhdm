// § vsTrailRangeColonJoin453
package p;
  class C;
    extern function void f(int i0);
  endclass
  function void C::f(int i0);
    logic [3:0][7:0] m;
    m[i0][i0+:2] = 1;
  endfunction
endpackage
module top;
  import p::*;
endmodule
