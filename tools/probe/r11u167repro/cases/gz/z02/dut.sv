// § genProcFoldDeclTsScopeNamed167
module top #(parameter int W = 8, parameter logic [W-1:0] Z = '0) (input logic clk, input logic [W-1:0] d, output logic [W-1:0] q);
  always_ff @(posedge clk) q <= Z;
endmodule
