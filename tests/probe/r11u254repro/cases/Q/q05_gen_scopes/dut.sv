// § pkgSelIdxRefColons254 (a package-qualified select in for and if generate continuous assignments and processes, two levels down)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 4, parameter int P = 1) (output logic [3:0] o [4], output logic [3:0] q);
  for (genvar k = 0; k < 4; k++) begin : gen_fwd
    assign o[k] = cp::RC[k][W-1:0];
    if (P == 1) begin : gi
      logic [3:0] t;
      always_comb t = cp::RC[0][W-1:0];
    end
  end
  if (P == 1) begin : g_if
    assign q = cp::RC[1][W-1:0];
  end
endmodule
