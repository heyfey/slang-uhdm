// § addOperandConstMint475 (residue: overflowing add)
package a;
  parameter logic [5:0] PA = 6'd63;
  parameter logic [5:0] PC = PA + 6'd1;
  parameter logic [7:0] PE = (PA + 1) + 2;
endpackage
module top(output logic [5:0] y, output logic [7:0] z);
  import a::*;
  assign y = PC;
  assign z = PE;
endmodule
