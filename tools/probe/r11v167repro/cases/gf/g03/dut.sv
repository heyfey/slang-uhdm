// § genProcFoldDeclTsScopeNamed167
module top #(parameter int W = 8, parameter logic [W-1:0] Z = '0) (input logic clk, output logic [W-1:0] q);
  if (W == 8) begin : g
    if (1) begin : h
      always_ff @(posedge clk) q <= Z;
    end
  end
endmodule
