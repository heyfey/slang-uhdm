// § genProcFoldDeclTsScopeNamed167
module sub #(parameter int W = 4, parameter logic [W-1:0] Z = '1) (input logic clk, input logic [W-1:0] d, output logic [W-1:0] q);
  if (1) begin : g
    always_ff @(posedge clk) q <= d ^ Z;
  end
endmodule
module top (input logic clk, input logic [7:0] d, output logic [3:0] q, output logic [7:0] r);
  sub u1 (.clk(clk), .d(d[3:0]), .q(q));
  sub #(.W(8), .Z(8'h3c)) u2 (.clk(clk), .d(d), .q(r));
endmodule
