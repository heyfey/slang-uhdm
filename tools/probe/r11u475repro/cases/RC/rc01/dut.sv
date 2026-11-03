// § pkgReadRefChainLitForm475
package a;
  parameter PA = 6'd33;
  parameter PB = PA;
  parameter logic [7:0] HA = 8'h2a;
  parameter logic [7:0] HB = HA;
  parameter logic [7:0] HC = HB;
endpackage
module top(output logic [5:0] y, output logic [7:0] z, output logic [7:0] w);
  import a::*;
  assign y = PB;
  assign z = HC;
  assign w = a::HB;
endmodule
