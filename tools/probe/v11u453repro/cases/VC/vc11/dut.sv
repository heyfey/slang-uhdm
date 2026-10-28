// § vsTrailRangeColonJoin453
package p;
  parameter int W = 2;
  function automatic logic [1:0] f(logic [3:0][7:0] m, int i0);
    return m[i0][W+:W];
  endfunction
endpackage
module top;
  import p::*;
  logic [3:0][7:0] q;
  logic [1:0] o;
  always_comb o = f(q, 1);
endmodule
