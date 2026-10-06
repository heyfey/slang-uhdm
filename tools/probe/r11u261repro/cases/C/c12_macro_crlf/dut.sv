// § pkgQualSelChainOwnName261
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
`define RCK(k, w) cp::RC[k][w-1:0]
module top #(parameter int W = 4) (input logic [3:0] a, output logic [3:0] o [4]);
  for (genvar k = 0; k < 4; k++) begin : gen_fwd
    assign o[k] = a ^ `RCK(k, W);
  end
endmodule
