// § genProcFoldDeclTsScopeNamed167
module top #(parameter int W = 8, parameter int V = 2, parameter logic [W+V-1:0] Z = '0) (input logic clk, output logic [W+V-1:0] q);
  if (W == 8) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
