// § vsTrailRangeColonJoin453
package p;
  function automatic void f(int i0);
    logic [3:0][3:0][7:0] m;
    m[1][2][i0+:2] = 1;
  endfunction
endpackage
module top;
  import p::*;
endmodule
