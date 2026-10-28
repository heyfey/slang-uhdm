// § vsTrailRangeColonJoin453
package p;
  function automatic void f(int i0, output logic [1:0] y);
    logic [3:0][7:0] m;
    y = m[i0][(i0)+:2] + m[1][i0-1-:2];
  endfunction
endpackage
module top;
  import p::*;
endmodule
