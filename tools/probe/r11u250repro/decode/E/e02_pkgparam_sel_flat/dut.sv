// § defGenPathSel161 (decode control, no law of r11u250: the same select outside a generate loop)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, output logic [3:0] o);
  assign o = a ^ cp::RC[1][W-1:0];
endmodule
