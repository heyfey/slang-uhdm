// § genProcFoldDeclTsScopeNamed167 — the parameter folded under an operation with a signal in a gen-for always_ff
module top #(parameter int W = 4, parameter logic [W-1:0] Z = 4'd3) (input logic clk, input logic [W-1:0] d, output logic [W-1:0] q [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    always_ff @(posedge clk) q[i] <= d ^ Z;
  end
endmodule
