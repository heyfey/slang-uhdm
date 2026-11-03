// § addOperandConstMint475
package a;
  parameter PA = 6'd33;
  parameter PB = PA;
  parameter PC = PA + 6'd1;
  parameter PD = PA + 1;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  assign y = PB;
  assign z = PC ^ PD;
endmodule
