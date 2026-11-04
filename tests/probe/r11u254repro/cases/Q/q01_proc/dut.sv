// § pkgSelIdxRefColons254 (a module parameter in a part-select bound and an index of a package-qualified select: named, unnamed blocks and a compound assignment)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, output logic [3:0] o, output logic [7:0] p);
  always_comb begin : nb
    o = a;
    o ^= cp::RC[0][W-1:0];
  end
  always_comb p = cp::R3[0][W-1];
endmodule
