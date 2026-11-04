// § addOperandConstMint475
package a;
  parameter logic [5:0] PA = 6'h21;
  parameter logic [5:0] PB = PA;
  parameter logic [5:0] PC = PA + 6'd1;
  parameter logic [5:0] PD = PA + 1;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  assign y = PB;
  assign z = PC ^ PD;
endmodule
