// § addOperandConstMint475
package a;
  typedef logic [5:0] t;
  parameter t PA = 6'd33;
  parameter t PB = PA;
  parameter t PC = PA + 6'd1;
  parameter t PD = PA + 1;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  assign y = PB;
  assign z = PC ^ PD;
endmodule
