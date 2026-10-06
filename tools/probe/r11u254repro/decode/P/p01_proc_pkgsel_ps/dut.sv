// § pkgSelIdxRefColons254 (decode: Earlgrey #214553 / #346618, a module parameter read in a part-select bound of a package parameter's select inside a named always_comb)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, output logic [3:0] o);
  always_comb begin : p_pre
    o = a;
    o ^= cp::RC[0][W-1:0];
  end
endmodule
