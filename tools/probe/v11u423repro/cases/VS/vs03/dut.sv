// § unszFoldWholeCaRhsKeepsSize423v (refining § unszBasedPkgFoldUnsized423)
package p;
  parameter H = 'h1F;
endpackage
module top(input int x, output logic [7:0] y);
  import p::*;
  wire [7:0] w = H;
  assign y = w;
endmodule
