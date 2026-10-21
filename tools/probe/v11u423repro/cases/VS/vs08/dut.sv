// § unszBasedPkgFoldUnsized423
package p;
  parameter S = 'sh1F;
  parameter D = 'sd7;
endpackage
module top(input int x, output int y, output int z);
  import p::*;
  assign y = x + S;
  assign z = x - D;
endmodule
