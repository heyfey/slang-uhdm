// § elabImpRefDecRespell475
// a two-hop chain and a signed based decimal
package a;
  parameter logic [5:0] PA = 6'd33;
  parameter logic [5:0] PB = PA;
  parameter logic [5:0] PC = PB;
  parameter logic signed [5:0] SA = 6'sd5;
  parameter logic signed [5:0] SB = SA;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  assign y = PC;
  assign z = SB;
endmodule
