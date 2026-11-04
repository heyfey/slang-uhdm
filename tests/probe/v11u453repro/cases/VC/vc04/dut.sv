// § vsTrailRangeColonJoin453
package p;
  function automatic logic [1:0] f(int i0);
    logic [3:0][7:0] m;
    logic [1:0] r;
    r = m[i0+1][i0*2+:2];
    return r;
  endfunction
endpackage
module top;
  import p::*;
  logic [1:0] o;
  assign o = f(1);
endmodule
