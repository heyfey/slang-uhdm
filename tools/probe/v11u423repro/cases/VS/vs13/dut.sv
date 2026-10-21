// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'h1F;
endpackage
module top(output int y, output logic [7:0] z, output int w);
  import p::*;
  always_comb y = H;
  always_comb z = H;
  initial w = H;
endmodule
