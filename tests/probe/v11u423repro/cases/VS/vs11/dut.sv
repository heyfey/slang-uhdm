// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'hFFFF_FFFF_F;
endpackage
module top(input longint x, output longint y);
  import p::*;
  assign y = x ^ H;
endmodule
