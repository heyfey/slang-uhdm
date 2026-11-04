// § unszFoldWholeCaRhsKeepsSize423v (refining § unszBasedPkgFoldUnsized423)
package p;
  parameter H = 'h1F;
endpackage
module top(input int x, output int y, output int z);
  assign y = x + p::H;
  assign z = p::H;
endmodule
