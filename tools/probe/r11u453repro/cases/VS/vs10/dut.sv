// § vsTrailRangeColonJoin453
package p;
  logic [3:0][7:0] g;
  task automatic t(int i0);
    g[i0][i0+:2] = 2;
  endtask
endpackage
module top;
  import p::*;
endmodule
