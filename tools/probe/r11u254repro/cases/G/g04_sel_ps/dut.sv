// § genCaPsBoundOpChain254 (a 2-D net with a genvar select then an operation part-select, an imported parameter width, two levels down)
package pk; parameter int D = 4; endpackage
module top #(parameter int W = 4) (input logic [1:0][7:0] a, output logic [3:0] o [2], output logic [3:0] q [2]);
  import pk::*;
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = a[k][W-1:0];
    for (genvar j = 0; j < 1; j++) begin : h
      assign q[k] = a[k][D*2-1:D];
    end
  end
endmodule
