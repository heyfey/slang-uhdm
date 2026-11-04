// § refChainHexWrittenCase475
// mixed-case hex digits through an import
package a;
  parameter logic [7:0] HA = 8'hAb;
  parameter logic [7:0] HB = HA;
endpackage
module top(output logic [7:0] y);
  import a::*;
  assign y = HB;
endmodule
