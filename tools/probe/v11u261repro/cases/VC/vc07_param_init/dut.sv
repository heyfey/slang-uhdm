// § pkgQualSelChainOwnName261
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 4) (output logic [3:0] o);
  localparam logic [3:0] X = cp::RC[1][W-1:0] + 1;
  assign o = X;
endmodule
