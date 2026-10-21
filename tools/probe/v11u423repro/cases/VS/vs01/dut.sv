// § unszFoldWholeCaRhsKeepsSize423v (refining § unszBasedPkgFoldUnsized423)
package p;
  parameter H = 'h1F;
endpackage
module top(output int y, output logic [7:0] z);
  import p::*;
  assign y = H;
  assign z = H;
endmodule
