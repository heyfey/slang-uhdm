// § addOperandConstMint475
// a 'd operand inside a continuous assignment and a port actual
module sub #(parameter int W = 1) (output logic [7:0] y);
  assign y = W;
endmodule
module top(output logic [7:0] y, output logic [7:0] z);
  parameter logic [5:0] PA = 6'd33;
  assign y = PA + 6'd1;
  sub #(.W(PA + 1)) u(z);
endmodule
