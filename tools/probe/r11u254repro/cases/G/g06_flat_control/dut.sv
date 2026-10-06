// § genCaPsBoundOpChain254 (control: the same selects outside generate scopes and in a generate process)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
endpackage
module top #(parameter int W = 4) (input logic [7:0] a, output logic [3:0] o, output logic [3:0] q [2]);
  assign o = a[W-1:0] ^ cp::RC[1][W-1:0];
  for (genvar k = 0; k < 2; k++) begin : g
    always_comb q[k] = a[W-1:0];
  end
endmodule
