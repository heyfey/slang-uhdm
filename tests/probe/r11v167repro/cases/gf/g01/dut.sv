// § genProcFoldDeclTsScopeNamed167
module top #(parameter int W = 8, parameter logic [7:0] Z = '0) (input logic clk, output logic [7:0] q);
  if (W == 8) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
