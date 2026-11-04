// § genProcFoldDeclTsScopeNamed167 — a select of the parameter (not a whole fold) in a gen-for process
module top #(parameter int W = 4, parameter logic [W-1:0] Z = 4'b1010) (input logic clk, output logic q [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    always_ff @(posedge clk) q[i] <= Z[i];
  end
endmodule
