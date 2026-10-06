// § pkgQualSelChainOwnName261
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
package dp;
  parameter logic [1:0][15:0] DC = {16'h1234, 16'h5678};
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, output logic [3:0] o [2], output logic [3:0] p [2]);
  for (genvar k = 0; k < 2; k++) begin : gen_fwd
    assign o[k] = a ^ cp::RC[k][W-1:0];
    assign p[k] = a ^ dp::DC[k][W-1:0];
  end
endmodule
