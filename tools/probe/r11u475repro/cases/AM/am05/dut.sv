// § addOperandConstMint475
package a;
  parameter logic [5:0] PA = 6'b100001;
  parameter logic [5:0] PB = PA;
  parameter logic [5:0] PC = PA - 6'd1;
  parameter logic [5:0] PD = 6'o41;
  parameter logic [5:0] PE = PD;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  assign y = PB ^ PE;
  assign z = PC;
endmodule
