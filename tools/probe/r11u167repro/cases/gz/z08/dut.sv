// § genProcFoldDeclTsScopeNamed167
module sub #(parameter int W = 4, parameter logic [W-1:0] Z = '1) (input logic clk, output logic [W-1:0] q);
  if (1) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
module top (input logic clk, output logic [3:0] q, output logic [7:0] r);
  sub u1 (.clk(clk), .q(q));
  sub #(.W(8)) u2 (.clk(clk), .q(r));
endmodule
