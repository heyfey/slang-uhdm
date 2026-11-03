// § elabImpRefDecRespell475
// a module parameter defined by a qualified package parameter
package a;
  parameter logic [5:0] PA = 6'd33;
endpackage
module top(output logic [5:0] y);
  parameter logic [5:0] PB = a::PA;
  assign y = PB;
endmodule
