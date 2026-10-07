// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects in an if-generate and a case-generate
module top #(parameter int M = 1)(input logic [1:0] k, output logic o, output logic q);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  if (M == 1) begin : gi
    assign o = z.g[k][1];
  end
  case (M)
    1: begin : gc
      assign q = z.g[k][0];
    end
    default: begin : gd
      assign q = 1'b0;
    end
  endcase
endmodule
