// residue (no law landed): a generate-block localparam select whose index is an operation names its operand refs under the select (TypeEmit emitSyntaxExpr, sister ground), see README
module top #(parameter int P[3:0] = '{6, 4, 2, 0}) (output logic [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam a_lp = P[i+1] + 1;
    localparam b_lp = P[i];
    assign o[i] = a_lp < b_lp;
  end
endmodule
module top_w; endmodule
