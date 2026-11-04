// § elabImpRefDecRespell475
// a child whose referenced parameter is overridden
module sub #(parameter logic [5:0] PA = 6'd33, parameter logic [5:0] PB = PA) (output logic [5:0] y);
  assign y = PB;
endmodule
module top(output logic [5:0] y1, y2);
  sub #(.PA(6'd7)) u1(y1);
  sub u2(y2);
endmodule
