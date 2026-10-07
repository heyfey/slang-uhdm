// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// an input struct port as the root, in a case statement selector and item
module top(input logic [8:0] pz, input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = pz;
  always_comb begin
    case (z.g[k][1])
      1'b1: o = z.g[k][0];
      default: o = 1'b0;
    endcase
  end
endmodule
