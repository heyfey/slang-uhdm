// residue, sister ground (TypeEmit emitSyntaxExpr): def-view generate ref_module concat bit_select at its index
module sub #(parameter W = 2) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule
module top (input logic [3:0] a, input logic [3:0] b, output logic [0:0] q1 [2], output logic [0:0] q2 [2], output logic [0:0] q3 [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.W(1)) u1 (.d(a[i]), .q(q1[i]));
    sub #(.W(1)) u2 (.d(~a[i+1]), .q(q2[i]));
    sub #(.W(1)) u3 (.d(a[i] & b[2]), .q(q3[i]));
  end
endmodule
