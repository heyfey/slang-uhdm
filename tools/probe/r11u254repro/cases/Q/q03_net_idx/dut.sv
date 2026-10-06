// § pkgSelIdxRefColons254 (a net, a variable and a genvar as the index of a package-qualified select)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top (input logic [1:0] i, output logic [7:0] o [2], output logic [7:0] p);
  logic [1:0] v;
  assign p = cp::RC[i];
  always_comb begin v = i; o[0] = cp::RC[v]; end
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = cp::RC[k];
  end
endmodule
