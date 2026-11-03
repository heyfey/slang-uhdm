// § elabImpRefDecRespell475
// an unsized based decimal through an import
package a;
  parameter int PA = 'd33;
  parameter int PB = PA;
endpackage
module top(output logic [31:0] y);
  import a::*;
  assign y = PB;
endmodule
