// § elabImpRefDecRespell475
// octal and hex origins through an import
package a;
  parameter logic [5:0] PO = 6'o41;
  parameter logic [5:0] PH = 6'h21;
  parameter logic [5:0] QO = PO;
  parameter logic [5:0] QH = PH;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  assign y = QO;
  assign z = QH;
endmodule
