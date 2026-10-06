// § pkgSelIdxRefColons254 (abstains: the select as a binary operand, a single select level, inside a cast and a comparison)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, input logic [31:0] b, output logic [3:0] o, output logic [3:0] p, output logic q);
  always_comb begin : nb
    o = a ^ cp::RC[1][W-1:0];
    p = a;
    p ^= cp::RC[W-1:0];
  end
  assign q = logic'(b[W-1:0] >= cp::RC[W-1:0]);
endmodule
