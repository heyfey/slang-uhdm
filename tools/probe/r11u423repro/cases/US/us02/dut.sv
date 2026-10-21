// § unszBasedPkgFoldUnsized423
package p;
  parameter R = 'hf000000;
endpackage
import p::*;
module top(input int x, output int y);
  assign y = x & R;
endmodule
