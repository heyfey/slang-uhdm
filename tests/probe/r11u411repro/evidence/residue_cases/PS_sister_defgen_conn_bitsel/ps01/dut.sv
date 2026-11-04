// residue, sister ground (TypeEmit emitSyntaxExpr): def-view generate ref_module concat bit_select at its index
module sub #(parameter W = 2) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule
module top #(parameter P = 1) (input logic [3:0] a, input logic [3:0] b, output logic [1:0] q0, output logic [1:0] q1 [2]);
  sub u0 (.d({a[P], b[2]}), .q(q0));
  for (genvar i = 0; i < 2; i++) begin : g
    sub u1 (.d({a[i], b[i+1]}), .q(q1[i]));
  end
endmodule
