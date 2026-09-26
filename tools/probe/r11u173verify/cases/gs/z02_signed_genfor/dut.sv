// § genProcFoldDeclTsScopeNamed167 — a signed logic parameter folded in a gen-for process
module top #(parameter int W = 4, parameter logic signed [W-1:0] Z = -2) (input logic clk, output logic signed [W-1:0] q [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    always_ff @(posedge clk) q[i] <= Z;
  end
endmodule
