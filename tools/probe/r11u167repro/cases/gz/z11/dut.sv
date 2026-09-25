// § genProcFoldDeclTsScopeNamed167
`define RST(q, z) always_ff @(posedge clk) q <= z;
module top #(parameter int W = 8, parameter logic [W-1:0] Z = '0) (input logic clk, output logic [W-1:0] q);
  if (W == 8) begin : g
    `RST(q, Z)
  end
endmodule
