// residue, sister ground (TypeEmit emitSyntaxExpr): def-view generate ref_module concat bit_select at its index
module sub #(parameter W = 2) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule
module top (input logic [3:0] a, output logic [0:0] q0);
  sub #(.W(1)) u0 (.d(~a[2]), .q(q0));
endmodule
