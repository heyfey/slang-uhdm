// § genProcFoldDeclTsScopeNamed167
module top #(parameter int W = 8) (input logic clk, output logic [W-1:0] q);
  localparam logic [W-1:0] Z = '1;
  if (W == 8) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
