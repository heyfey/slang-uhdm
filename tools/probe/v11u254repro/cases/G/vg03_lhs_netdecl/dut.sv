// § genCaPsBoundOpChain254 (a part-select target with operation bounds, a net declaration assignment and a generate-local net)
module top #(parameter int W = 4) (input logic [7:0] a, output logic [7:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    wire [3:0] t = a[W+3:W];
    logic [3:0] u;
    assign u = t;
    assign o[k][W-1:0] = u;
    assign o[k][W*2-1:W] = a[W-1:0];
  end
endmodule
