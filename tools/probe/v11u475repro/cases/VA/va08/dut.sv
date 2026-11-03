// § addOperandConstMint475
// a 'd default overridden by a hex actual, and a hex default overridden by a 'd actual
module sub #(parameter logic [5:0] PA = 6'd33, parameter logic [5:0] PB = 6'h3, parameter logic [5:0] PC = PA + 1, parameter logic [5:0] PD = PB + 1) (output logic [5:0] y, output logic [5:0] z);
  assign y = PC;
  assign z = PD;
endmodule
module top(output logic [5:0] y1, z1, y2, z2);
  sub #(.PA(6'h9), .PB(6'd4)) u1(y1, z1);
  sub u2(y2, z2);
endmodule
