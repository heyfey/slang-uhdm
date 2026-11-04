// § genProcFoldDeclTsScopeNamed167
module top #(parameter int W = 8, parameter logic [W-1:0] Z = '0) (input logic clk, input logic rst, input logic [W-1:0] d, output logic [W-1:0] q);
  for (genvar i = 0; i < 1; i++) begin : g
    always_ff @(posedge clk) begin
      if (rst) q <= Z;
      else q <= d;
    end
  end
endmodule
