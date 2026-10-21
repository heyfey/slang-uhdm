// § unszFoldWholeCaRhsKeepsSize423v (refining § unszBasedPkgFoldUnsized423)
package p;
  parameter H = 'd200;
endpackage
module top(output logic [7:0] y, output logic [15:0] z);
  import p::*;
  wire [15:0] w = H;
  assign y = p::H;
  assign z = w;
endmodule
