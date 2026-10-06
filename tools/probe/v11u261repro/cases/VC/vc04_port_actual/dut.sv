// § pkgQualSelChainOwnName261
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module leaf (input logic [3:0] x, output logic [3:0] y);
  assign y = x;
endmodule
module top #(parameter int W = 4) (output logic [3:0] o);
  leaf l (.x(cp::RC[1][W-1:0]), .y(o));
endmodule
