// § defGenPathSel161 (decode only, no law of r11u250: Earlgrey #214684 / #214686, a package parameter's var_select / part_select in a generate loop)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, output logic [3:0] o [4]);
  for (genvar k = 0; k < 4; k++) begin : gen_fwd
    assign o[k] = a ^ cp::RC[k][W-1:0];
  end
endmodule
