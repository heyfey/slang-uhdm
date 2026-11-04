// § pkgSelIdxRefColons254 (decode: the same select written through a wildcard import, unqualified)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
module top #(parameter int W = 4) (output logic [3:0] o);
  import cp::*;
  assign o = RC[0][W-1:0];
endmodule
