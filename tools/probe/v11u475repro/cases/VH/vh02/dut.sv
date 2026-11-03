// § refChainHexWrittenCase475
// lowercase hex with x digits and underscores
package a;
  parameter logic [15:0] HA = 16'hx_ab;
  parameter logic [15:0] HB = HA;
  parameter logic [15:0] HC = 16'hde_ad;
  parameter logic [15:0] HD = HC;
endpackage
module top(output logic [15:0] y, output logic [15:0] z);
  import a::*;
  assign y = HB;
  assign z = HD;
endmodule
