// residue, sister ground (TypeEmit emitSyntaxExpr): def-view generate ref_module concat bit_select at its index
module sub #(parameter W = 2) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule
module top (input logic [3:0] a, output logic [1:0] q0);
  wire [1:0] w = {a[0], a[1]};
  sub u0 (.d(w), .q(q0));
endmodule
