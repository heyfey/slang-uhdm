// residue, sister ground (TypeEmit emitSyntaxExpr): def-view generate ref_module concat bit_select at its index
module sub #(parameter W = 2) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule
module top (input logic [3:0] a, input logic [7:0] b, output logic [1:0] q1 [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    sub u1 (.d({a[i], b[2*i+1]}), .q(q1[i]));
  end
endmodule
