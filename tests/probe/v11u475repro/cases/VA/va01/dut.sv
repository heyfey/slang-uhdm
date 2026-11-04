// § addOperandConstMint475
// a plain decimal origin and a hex literal operand stay UINT
package a;
  parameter logic [5:0] PA = 33;
  parameter logic [5:0] PC = PA + 1;
  parameter logic [5:0] PD = PA + 6'h1;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  assign y = PC;
  assign z = PD;
endmodule
