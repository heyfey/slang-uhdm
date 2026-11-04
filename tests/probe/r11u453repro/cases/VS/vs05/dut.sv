// § vsTrailRangeColonJoin453
package p;
  class C;
    logic [3:0][7:0] m;
    function void f(int i0);
      m[1][i0+:2] = 1;
    endfunction
  endclass
endpackage
module top;
  import p::*;
endmodule
