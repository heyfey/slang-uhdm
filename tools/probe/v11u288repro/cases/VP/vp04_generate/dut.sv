// § parenCastReadsCastSyntax288 — a parenthesized cast in generate conditions, loop bounds and generate bodies over a genvar
module top #(parameter int W = 3)(input logic [7:0] x, output logic [7:0] o);
  if ((int'(W)) > 2) begin : g1
    assign o[0] = (int'(x[0]));
  end
  for (genvar g = 0; g < (int'(W)); g++) begin : gl
    assign o[g + 1] = x[(int'(g))] ^ (byte'(g));
  end
  case ((int'(W)))
    3: begin : gc assign o[7] = (shortint'(x)) > 1; end
    default: begin : gd assign o[7] = 1'b0; end
  endcase
endmodule
