// § vsTrailRangeColonJoin453
package p;
  parameter int W = 2;
  parameter int P = 3;
  function automatic void f(int i0);
    logic [3:0][7:0] m;
    m[i0][i0+:W] = 1;
    m[i0][P:0] = 1;
  endfunction
endpackage
module top;
  import p::*;
endmodule
