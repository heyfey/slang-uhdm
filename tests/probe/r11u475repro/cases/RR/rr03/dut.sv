// § elabImpRefDecRespell475
// CONTROL a module's own parameter defined by another (no import)
module top(output logic [5:0] y);
  parameter logic [5:0] PA = 6'd33;
  localparam logic [5:0] PB = PA;
  assign y = PB;
endmodule
