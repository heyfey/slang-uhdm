// § pkgQualSelChainOwnName261
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
  parameter logic [7:0] V = 8'h5a;
endpackage
module top #(parameter int W = 4) (input logic [3:0][7:0] arr, input logic [3:0] a, output logic [3:0] o [4]);
  for (genvar k = 0; k < 4; k++) begin : gen_fwd
    assign o[k] = a ^ arr[k][W-1:0];
  end
endmodule
