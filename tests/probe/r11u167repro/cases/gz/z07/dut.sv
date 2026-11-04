// § genProcFoldDeclTsScopeNamed167
module top #(parameter int W = 8, parameter logic [W-1:0][1:0] Z = '0) (input logic clk, output logic [2*W-1:0] q);
  if (1) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
