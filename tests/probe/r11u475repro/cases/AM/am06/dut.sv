// § addOperandConstMint475
package a;
  parameter int PA = 33;
  parameter int PB = PA;
  parameter int PC = PA + 1;
  parameter logic [7:0] PD = PA * 2;
endpackage
module top(output logic [7:0] y, output logic [7:0] z);
  import a::*;
  assign y = PB;
  assign z = PC ^ PD;
endmodule
