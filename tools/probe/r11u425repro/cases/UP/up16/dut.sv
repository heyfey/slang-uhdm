// § unszBinNdaKeepsTickText425
// 'b101 read nq (grid g1/g16)
package p;
  parameter H = 'b101;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  wire [7:0] w = p::H; assign y = w;
endmodule
