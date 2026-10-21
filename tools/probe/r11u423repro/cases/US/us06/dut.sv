// § unszBasedPkgFoldUnsized423 (control: sized, typed, ranged and 'b1 token defaults, not reached)
package p;
  parameter S = 8'hF0;
  parameter int T = 'hF0;
  parameter [7:0] G = 'hF0;
  parameter B = 'b1;
endpackage
import p::*;
module top(input int x, output int y);
  assign y = ((x & S) | T) ^ (G + B);
endmodule
