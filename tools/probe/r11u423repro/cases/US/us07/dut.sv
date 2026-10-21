// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'h1F;
  parameter O = 'o17;
endpackage
module top(input int x, output int y, output int z);
  import p::*;
  assign y = x + H;
  always_comb z = x - O;
endmodule
