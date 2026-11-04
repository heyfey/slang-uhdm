// residue, sister ground (TypeEmit emitSyntaxExpr): def-view generate ref_module concat bit_select at its index
module sub #(parameter W = 2) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule
module top #(parameter E = 1) (input logic [3:0] a, input logic [3:0] b, output logic [1:0] q0);
  if (E) begin : g
    sub u1 (.d({a[E], b[3]}), .q(q0));
  end
endmodule
