// § addOperandConstMint475
module top(output logic [5:0] y, output logic [5:0] z);
  parameter logic [5:0] PA = 6'd33;
  parameter logic [5:0] PB = PA;
  parameter logic [5:0] PC = PA + 6'd1;
  localparam logic [5:0] PD = PA + 1;
  assign y = PB;
  assign z = PC ^ PD;
endmodule
