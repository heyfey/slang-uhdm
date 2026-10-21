// § unszFoldWholeCaRhsKeepsSize423v (refining § unszBasedPkgFoldUnsized423)
package p;
  parameter H = 'h1F;
endpackage
interface ifc;
  import p::*;
  logic [5:0] b;
  assign b = H;
endinterface
module top(output logic [3:0] y, output int z);
  import p::*;
  ifc u();
  for (genvar i = 0; i < 1; i++) begin : g
    assign y = H;
  end
  assign z = (H);
endmodule
