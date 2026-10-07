// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// if-generate and case-generate scopes with a generate-local localparam index
module top #(parameter int M = 1)(input logic [1:0] k, output logic o, output logic p);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  if (M == 1) begin : gi
    localparam int L = 2;
    assign o = z.g[L][k[0]];
  end
  case (M)
    1: begin : gc assign p = z.g[k][1]; end
    default: begin : gd assign p = 1'b0; end
  endcase
endmodule
