// § pkgSelIdxRefColons254 (decode: a package parameter's single part-select in a named block)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, input logic [1:0][7:0] n, output logic [3:0] o);
  always_comb begin : p_pre
    o = cp::RC[W-1:0];
  end
endmodule
