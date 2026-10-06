// § pkgQualSelChainOwnName261
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top (output logic [7:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = {cp::RC[k][3:0], cp::RC[k+1][7:4]} + 1;
  end
endmodule
