// residue (no law landed): a generate-block localparam select whose index is an operation names its operand refs under the select (TypeEmit emitSyntaxExpr, sister ground), see README
module top (input logic [7:0] v, output logic [7:0] o);
  for (genvar i = 0; i < 4; i++) begin : g
    assign o[i] = v[i+1];
  end
endmodule
