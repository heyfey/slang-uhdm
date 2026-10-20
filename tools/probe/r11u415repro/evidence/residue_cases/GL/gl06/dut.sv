// residue (no law landed): a generate-block localparam select whose index is an operation names its operand refs under the select (TypeEmit emitSyntaxExpr, sister ground), see README
module top #(parameter logic [7:0] P = 8'h5a) (output logic [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam a_lp = P[i+1];
    localparam b_lp = P[i*2+:2];
    assign o[i] = a_lp ^ b_lp[0];
  end
endmodule
module top_w; endmodule
