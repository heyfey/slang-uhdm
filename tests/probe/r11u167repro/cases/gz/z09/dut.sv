// § genProcFoldDeclTsScopeNamed167
module top #(parameter int W = 8, parameter bit [W-1:0] Z = '1) (input logic clk, output logic [W-1:0] q);
  if (W == 8) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
