// § elabImpRefDecRespell475
// a module-local reference chain to a based decimal, no package
module top(output logic [5:0] y);
  parameter logic [5:0] PA = 6'd33;
  parameter logic [5:0] PB = PA;
  assign y = PB;
endmodule
