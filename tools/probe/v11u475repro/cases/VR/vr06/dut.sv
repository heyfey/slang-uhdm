// § elabImpRefDecRespell475
// a 64-bit decimal through an import
package a;
  parameter logic [63:0] PA = 64'd18446744073709551615;
  parameter logic [63:0] PB = PA;
endpackage
module top(output logic [63:0] y);
  import a::*;
  assign y = PB;
endmodule
