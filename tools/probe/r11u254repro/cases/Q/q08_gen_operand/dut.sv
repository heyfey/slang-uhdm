// § pkgSelIdxRefColons254 (a for-generate continuous assignment with the select as an operand and as the whole right side)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, output logic [3:0] o [4], output logic [3:0] p [4]);
  for (genvar k = 0; k < 4; k++) begin : gen_fwd
    assign o[k] = a ^ cp::RC[k][W-1:0];
    assign p[k] = cp::RC[k][W-1:0];
  end
endmodule
