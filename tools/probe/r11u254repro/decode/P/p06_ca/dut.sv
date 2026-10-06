// § pkgSelIdxRefColons254 (decode: the same select in a continuous assignment)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, input logic [1:0][7:0] n, output logic [3:0] o);
  assign o = cp::RC[0][W-1:0];
endmodule
