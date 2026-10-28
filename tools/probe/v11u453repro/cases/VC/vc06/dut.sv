// § vsTrailRangeColonJoin453
package p;
  logic [3:0][7:0] pm;
  task automatic t(int i0);
    pm[i0][i0+:2] = 1;
  endtask
endpackage
module top;
  import p::*;
  initial t(0);
endmodule
