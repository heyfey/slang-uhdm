// § addOperandConstMint475
// an enum member operand and a cast operand beside a 'd literal
package a;
  typedef enum logic [3:0] {E0 = 4'd2, E1} e_t;
  parameter logic [5:0] PC = E1 + 6'd1;
  parameter logic [5:0] PD = 6'(3) + 6'd1;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  assign y = PC;
  assign z = PD;
endmodule
