// residue (no law landed): a generate-block localparam select whose index is an operation names its operand refs under the select (TypeEmit emitSyntaxExpr, sister ground), see README
module top #(parameter int dims_p = 2, parameter int P[dims_p:0] = '{4, 2, 0}) (output logic [7:0] o);
  genvar i;
  for (i = 0; i < dims_p; i = i + 1) begin : rof
    localparam up_lp = P[i+1];
    localparam lo_lp = P[i];
    assign o[i] = up_lp > lo_lp;
  end
endmodule
module top_w; endmodule
