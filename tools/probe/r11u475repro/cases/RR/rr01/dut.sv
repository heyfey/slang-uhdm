// § elabImpRefDecRespell475
// a package parameter defined by another (decimal) read by a module through an import
package a;
  typedef logic [5:0] t;
  parameter t PA = 6'd33;
  parameter t PB = PA;
  parameter logic [7:0] PH = 8'hab;
  parameter logic [7:0] PG = PH;
endpackage
module top(output logic [5:0] y, output logic [7:0] z);
  import a::*;
  assign y = PB;
  assign z = PG;
endmodule
