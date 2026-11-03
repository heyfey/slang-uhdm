// § addOperandConstMint475
// an unsized based decimal origin and a 'd operand
package a;
  parameter int PA = 'd33;
  parameter int PC = PA + 1;
  parameter int PD = 7 + 'd2;
endpackage
module top(output logic [31:0] y, output logic [31:0] z);
  import a::*;
  assign y = PC;
  assign z = PD;
endmodule
